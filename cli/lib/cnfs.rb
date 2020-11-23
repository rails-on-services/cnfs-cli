# frozen_string_literal: true

require 'little-plugger'
require 'pathname'
require 'config'
require 'xdg'

# rubocop:disable Metrics/ModuleLength
module Cnfs
  PROJECT_FILE = 'config/project.yml'
  extend LittlePlugger
  module Plugins; end
  class Error < StandardError; end

  class Logger
    attr_accessor :output

    def initialize(file = nil)
      @output = file ? Cnfs.project_root.join('tmp/log.txt') : 'screen'
    end

    def info(msg)
      log(msg) if Cnfs.config.debug.positive?
    end

    def debug(msg)
      log(msg) if Cnfs.config.debug > 1
    end

    private

    def log(msg)
      if output.eql?('screen')
        puts(msg)
      else
        File.open(output, 'a') { |f| f.puts(msg) }
      end
    end
  end

  class << self
    attr_accessor :repository, :project
    attr_reader :config
    attr_reader :timers, :logger, :cwd

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize!
      @timers = {}
      @cwd = Pathname.new(Dir.pwd)
      validate_command if project_root.nil?
      @logger = Logger.new
      start_time = Time.now
      Dir.chdir(project_root) do
        load_config
        require_minimum_deps
        config.dig(:cli, :dev) ? initialize_development : initialize_plugins
        setup_loader
        setup_extensions
        MainController.start
      end
      Cnfs.logger.info(timers.map { |k, v| "#{k}: #{v}" }.join("\n"))
      Cnfs.logger.info("wall time: #{Time.now - start_time}")
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def require_minimum_deps
      with_timer('loading core dependencies') { require_relative 'cnfs/minimum_dependencies' }
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable %w[aws cnfs dns kubernetes postgres rails redis]
      end
    end

    # rubocop:disable Metrics/MethodLength
    def load_config
      Config.env_separator = '_'
      Config.env_prefix = 'CNFS'
      Config.use_env = true
      ENV['CNFS_ENVIRONMENT'] = ENV.delete('CNFS_ENV')
      ENV['CNFS_NAMESPACE'] = ENV.delete('CNFS_NS')
      ENV['CNFS_REPOSITORY'] = ENV.delete('CNFS_REPO')
      @config = Config.load_files(gem_root.join(PROJECT_FILE), user_root.join('cnfs.yml'), PROJECT_FILE)
      Config.use_env = false
      config.debug ||= 0
    rescue StandardError => _e
      raise Cnfs::Error, "Error parsing config. Environment:\n#{`env | grep CNFS`}"
    end
    # rubocop:enable Metrics/MethodLength

    def initialize_development
      require 'pry'
      initialize_dev_plugins
    end

    # Emulate LittlePlugger's initialize process when in development mode
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize_dev_plugins
      gem_root.join('..').children.select(&:directory?).each do |dir|
        plugin_dir = dir.join('lib/cnfs/plugins')
        next unless plugin_dir.directory?

        plugin_dir.children.each do |file|
          name = File.basename(file).delete_suffix('.rb')
          plugin_module = "cnfs/plugins/#{name}"
          lib_path = File.expand_path(dir.join('lib'))
          $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
          require plugin_module
          next unless (klass = plugin_module.classify.safe_constantize)

          cmd = "initialize_#{name}"
          klass.send(cmd) if klass.respond_to?(cmd)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def require_deps
      with_timer('loading dependencies') { require_relative 'cnfs/dependencies' }
    end

    # def initialize_repositories
    #   return unless Cnfs.paths.src.exist?

    #   Cnfs.paths.src.children.select(&:directory?).each do |repo_path|
    #     repo_config_path = repo_path.join('cnfs/repository.yml')
    #     Cnfs.logger.info "Scanning repository path #{repo_path}"
    #     next unless repo_config_path.exist? && (name = YAML.load_file(repo_config_path)['name'])

    #     Cnfs.logger.info "Loading repository path #{repo_path}"
    #     config = YAML.load_file(repo_config_path).merge(path: repo_path)
    #     repositories[name.to_sym] = Thor::CoreExt::HashWithIndifferentAccess.new(config)
    #   end
    #   @repository = current_repository
    #   Cnfs.logger.info "Current repository set to #{repository&.name}"
    # end

    # Zeitwerk based class loader methods
    def setup_loader
      add_plugin_autoload_paths
      add_repository_autoload_paths
      Zeitwerk::Loader.default_logger = method(:puts) if config.debug > 1
      autoload_dirs.each { |dir| loader.push_dir(dir) }

      loader.enable_reloading
      loader.setup
    end

    def reload
      load_config
      loader.reload
      Cnfs::Configuration.reload
    end

    def loader
      @loader ||= Zeitwerk::Loader.new
    end

    def autoload_dirs
      @autoload_dirs ||= autoload_all(gem_root)
    end

    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
    end

    def project_root
      @project_root ||= cwd.ascend { |path| break path if path.join(PROJECT_FILE).file? }
    end

    def paths
      @paths ||= config.paths.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
    end

    def autoload_all(path)
      path.join('app').children.select(&:directory?).select { |m| default_load_paths.include?(m.split.last.to_s) }
    end

    # Scan plugsin for subdirs in <plugin_root>/app and add them to autoload_dirs
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def add_plugin_autoload_paths
      plugins.sort.each do |namespace, plugin|
        next unless (plugin = "cnfs/cli/#{namespace}".classify.safe_constantize)

        gem_load_paths = plugin.respond_to?(:load_paths) ? plugin.load_paths : %w[app]
        plugin_load_paths = plugin.respond_to?(:plugin_load_paths) ? plugin.plugin_load_paths : default_load_paths

        gem_load_paths.each do |load_path|
          load_path = plugin.gem_root.join(load_path)
          next unless load_path.exist?

          paths_to_load = load_path.children.select do |p|
            p.directory? && plugin_load_paths.include?(p.split.last.to_s)
          end
          autoload_dirs.concat(paths_to_load)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def default_load_paths
      %w[controllers generators helpers models]
    end

    # Scan repositories for subdirs in <repository_root>/cnfs/app and add them to autoload_dirs
    # TODO: plugin and repository load paths should work the same way and follow same class structures
    # So there should just be one method to populate autoload_dirs
    # TODO: This needs to be refactored b/c repositories are not in the Cnfs.repositories array now
    def add_repository_autoload_paths
      repositories.each do |_name, config|
        cnfs_load_path = Cnfs.project_root.join(config.path, 'cnfs/app')
        next unless cnfs_load_path.exist?

        paths_to_load = cnfs_load_path.children.select(&:directory?)
        autoload_dirs.concat(paths_to_load)
      end
    end

    def repositories
      @repositories ||= {}
    end

    def extensions
      @extensions ||= []
    end

    # Extensions found in autoload_dirs are configured to be loaded at a pre-defined extension point
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def setup_extensions
      # Ignore the extension points which are the controllers in the cli core gem
      Cnfs.logger.info 'Loaded Extensions:'
      autoload_dirs.select { |p| p.split.last.to_s.eql?('controllers') }
                   .reject { |p| p.join('../..').split.last.to_s.eql?('cli') }.each do |controllers_path|
        Dir.chdir(controllers_path) do
          Dir['**/*.rb'].each do |extension_path|
            extension = extension_path.delete_suffix('.rb')
            next unless (klass = extension.camelize.safe_constantize)

            namespace = extension.split('/').first
            extension_point = extension.delete_prefix("#{namespace}/").camelize
            extensions << Thor::CoreExt::HashWithIndifferentAccess.new(
              klass: klass, extension_point: extension_point,
              title: klass.respond_to?(:title) ? klass.title : namespace,
              help: klass.respond_to?(:help_text) ? klass.help_text : "#{namespace} SUBCOMMAND",
              description: klass.respond_to?(:description) ? klass.description : ''
            )
            Cnfs.logger.info "#{klass} #{' ' * (40 - klass.to_s.size)} => #{extension_point}"
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def invoke_plugins_with(method, *options)
      plugins_responding_to(method).each do |plugin|
        options.empty? ? plugin.send(method) : plugin.send(method, options)
      end
    end

    def plugins_responding_to(method)
      plugins.values.select { |klass| klass.plugin_lib.respond_to?(method) }.collect(&:plugin_lib)
    end

    def validate_command
      # Display help for new command when no arguments are passed
      ARGV.append('help', 'new') if ARGV.size.zero?
      command = %w[dev help new version].each do |valid_command|
        break [valid_command] if valid_command.start_with?(ARGV[0])
      end
      raise Cnfs::Error, 'Not a cnfs project' unless command.size.eql?(1)

      @project_root = '.'
    end

    def reset
      ARGV.shift # remove 'new'
      @cwd = Pathname.new(Dir.pwd)
      @project_root = nil
      @paths = nil
      Dir.chdir(project_root) { load_config }
    end

    def with_timer(title = '', level = :info)
      start_time = Time.now
      Cnfs.logger.send(level, "Start #{title} at #{start_time}")
      yield
      timers[title] = Time.now - start_time
      Cnfs.logger.send(level, "Completed #{title} in #{Time.now - start_time} seconds")
    end

    # OS methods
    def gid
      ext_info = OpenStruct.new
      if RbConfig::CONFIG['host_os'] =~ /linux/ && Etc.getlogin
        shell_info = Etc.getpwnam(Etc.getlogin)
        ext_info.puid = shell_info.uid
        ext_info.pgid = shell_info.gid
      end
      ext_info
    end

    def capabilities
      @capabilities ||= set_capabilities
    end

    def set_capabilities
      cmd = TTY::Command.new(printer: :null)
      installed_tools = missing_tools = []
      tools.each do |tool|
        if cmd.run!("which #{tool}").success?
          installed_tools.append(tool)
        else
          missing_tools.append(tool)
        end
      end
      Cnfs.logger.info "Missing dependency tools [#{tools.join(', ')}]" if missing_tools.any?
      installed_tools
    end

    def tools
      %i[docker skaffold git ansible docker-compose terraform]
    end

    def platform
      os = case RbConfig::CONFIG['host_os']
      when /linux/
        'linux'
      when /darwin/
        'darwin'
      else
        'unknown'
      end
      ActiveSupport::StringInquirer.new(os)
    end

    # def git
    #   return Config::Options.new unless system('git rev-parse --git-dir > /dev/null 2>&1')

    #   Config::Options.new(
    #     tag_name: `git tag --points-at HEAD`.chomp,
    #     branch_name: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
    #     sha: `git rev-parse --short HEAD`.chomp
    #   )
    # end

    def silence_output(enforce = config.debug.zero?)
      rs = $stdout
      $stdout = StringIO.new if enforce
      yield
      $stdout = rs
    end

    def user_root
      @user_root ||= xdg.config_home.join('cnfs')
    end

    def xdg
      @xdg ||= XDG::Environment.new
    end
  end
end
# rubocop:enable Metrics/ModuleLength
