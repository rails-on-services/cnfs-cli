# frozen_string_literal: true

require 'little-plugger'
require 'pathname'
require 'config'
require 'xdg'

module Cnfs
  extend LittlePlugger
  module Plugins; end

  class Error < StandardError; end

  class Logger
    def info(msg)
      puts msg if Cnfs.config.debug.positive?
    end

    def debug(msg)
      puts msg if Cnfs.config.debug > 1
    end
  end

  class << self
    attr_accessor :autoload_dirs, :cwd, :repository, :app
    attr_reader :config, :project_root, :repository_root, :logger, :timers

    def reset
      ARGV.shift # remove 'new'
      @cwd = Pathname.new(Dir.pwd)
      @project_root = nil
      @repository_root = nil
      Dir.chdir(project_root) { load_config }
    end

    def initialize!
      # TODO: Get reset to be the common method here
      @timers = {}
      @logger = Logger.new
      @cwd = Pathname.new(Dir.pwd)
      # Display help for new command when no argument is passed
      ARGV.unshift('help', 'new') if ARGV.size.zero? && project_root.nil?
      raise Cnfs::Error, 'Not a cnfs project' unless project_root

      s = Time.now
      Dir.chdir(project_root) do
        load_config
        with_timer('loading minimum deps') { require_minimum_deps }
        config.dig(:cli, :dev) ? initialize_development : initialize_plugins
        setup_loader
        add_extensions
        MainController.start
      end
      Cnfs.logger.info(timers.map { |k, v| "#{k}: #{v}" }.join("\n"))
      Cnfs.logger.info("wall time: #{Time.now - s}")
    end

    def initialize_development
      require 'pry'
      initialize_dev_plugins
    end

    def with_timer(title = '', level = :info)
      start_time = Time.now
      Cnfs.logger.send(level, "Start #{title} at #{start_time}")
      yield
      timers[title] = Time.now - start_time
      Cnfs.logger.send(level, "Completed #{title} in #{Time.now - start_time} seconds")
    end

    def require_minimum_deps
      minimum_deps.each { |dep| require dep }
      minimum_deps_rel.each { |dep| require_relative dep }
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable %w[aws cnfs dns kubernetes postgres rails redis]
      end
    end

    def require_deps
      deps.each { |dep| require dep }
      deps_rel.each { |dep| require_relative dep }
    end

    def minimum_deps
      %w[active_support/concern active_support/inflector active_support/core_ext/hash/keys
         active_support/core_ext/enumerable fileutils thor thor/hollaback zeitwerk]
    end

    def minimum_deps_rel
      %w[cnfs/errors cnfs/version ext/config/options ext/string]
    end

    def deps
      # NOTE: require rails/railtie before lockbox
      # json_schemer open3
      %w[active_record active_record/fixtures active_support/core_ext/enumerable
         active_support/log_subscriber active_support/string_inquirer rails/railtie
         lockbox open-uri sqlite3]
    end

    def deps_rel
      %w[cnfs/schema]
    end

    def load_config
      Config.env_separator = '_'
      Config.env_prefix = 'CNFS'
      Config.use_env = true
      ENV['CNFS_ENVIRONMENT'] = ENV.delete('CNFS_ENV')
      ENV['CNFS_NAMESPACE'] = ENV.delete('CNFS_NS')
      ENV['CNFS_REPOSITORY'] = ENV.delete('CNFS_REPO')
      @config = Config.load_files(gem_root.join('config', 'cnfs.yml'), user_root.join('cnfs.yml'), 'cnfs.yml')
      Config.use_env = false
      config.debug ||= 0
    end

    # Emulate LittlePlugger's initialize process when in development mode
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
          next unless (klass = plugin_module.camelize.safe_constantize)

          cmd = "initialize_#{name}"
          klass.send(cmd) if klass.respond_to?(cmd)
        end
      end
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
      project&.reload
      loader.reload
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
      @project_root ||= begin
        return '.' if %w[dev help new version].include?(ARGV[0])

        cwd.ascend { |path| break path if path.join('cnfs.yml').file? }
      end
    end

    # Determine the current repository from where the user is in the project filesystem
    # Returns the default repository unless the user is in the path of another project repository
    def current_repository
      return unless project_root.class.name.eql?('Pathname')

      current_path = cwd.to_s
      src_path = project_root.join(paths.src).to_s
      return app.repository if current_path.eql?(src_path) || !current_path.start_with?(src_path)

      repo_name = current_path.delete_prefix(src_path).split('/')[1]
      app.repositories.find_by(name: repo_name)
    end

    def paths
      @paths ||= config.paths.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
    end

    def autoload_all(path)
      path.join('app').children.select(&:directory?).select { |m| %w[controllers helpers models generators].include?(m.split.last.to_s) }
    end

    # Scan plugsin for subdirs in <plugin_root>/app and add them to autoload_dirs
    def add_plugin_autoload_paths
      plugins.sort.each do |namespace, plugin|
        next unless (plugin = "cnfs/cli/#{namespace}".classify.safe_constantize)

        gem_load_paths = plugin.respond_to?(:load_paths) ? plugin.load_paths : %w[app]
        plugin_load_paths = plugin.respond_to?(:plugin_load_paths) ? plugin.plugin_load_paths : %w[controllers generators models]

        gem_load_paths.each do |load_path|
          load_path = plugin.gem_root.join(load_path)
          next unless load_path.exist?

          paths_to_load = load_path.children.select { |p| p.directory? && plugin_load_paths.include?(p.split.last.to_s) }
          autoload_dirs.concat(paths_to_load)
        end
      end
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
    def add_extensions
      # Ignore the extension points which are the controllers in the cli core gem
      Cnfs.logger.info "Loaded Extensions:"
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

    def invoke_plugins_wtih(method, *options)
      plugins_responding_to(method).each do |plugin|
        options.empty? ? plugin.send(method) : plugin.send(method, options)
      end
    end

    def plugins_responding_to(method)
      plugins.values.select { |klass| klass.plugin_lib.respond_to?(method) }.collect(&:plugin_lib)
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
      ary = []
      ary.append(:docker) if system('which docker')
      ary.append(:compose) if system('which docker-compose')
      ary.append(:skaffold) if system('which skaffold')
      ary.append(:git) if system('which git')
      ary.append(:ansible) if system('which ansible')
      ary.append(:terraform) if system('which terraform')
      ary
    end

    def platform
      case RbConfig::CONFIG['host_os']
      when /linux/
        'linux'
      when /darwin/
        'darwin'
      end
    end

    # def git
    #   return Config::Options.new unless system('git rev-parse --git-dir > /dev/null 2>&1')

    #   Config::Options.new(
    #     tag_name: `git tag --points-at HEAD`.chomp,
    #     branch_name: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
    #     sha: `git rev-parse --short HEAD`.chomp
    #   )
    # end

    def silence_output(enforce)
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
