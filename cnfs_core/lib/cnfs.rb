# frozen_string_literal: true

require 'config'
require 'tty-logger'
require 'xdg'

# rubocop:disable Metrics/ModuleLength
module Cnfs
  # class Error < StandardError; end

  class << self
    # attr_accessor :repository, :project
    attr_accessor :project
    # Injected values
    attr_accessor :project_file, :plugin_root
    attr_reader :config, :timers, :logger, :cwd

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize!
      @timers = {}
      @cwd = Pathname.new(Dir.pwd)
      validate_command if project_root.nil?
      Dir.chdir(project_root) do
        load_config
        configure_logger
        require_minimum_deps
        yield :before_loader if block_given? # client's call to initialize_plugins
        setup_loader
        setup_extensions
        yield :after_loader if block_given? # client's call to cli
      end
      logger.info(timers.map { |k, v| "\n#{k}:#{' ' * (30 - k.length)}#{v.round(2)}" }.join)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def parsable_files
      @parsable_files ||= source_files.group_by { |path| path.split('/').last.delete_suffix('.yml') }
    end

    def source_files
      @source_files ||= source_paths_map.values.flatten.map { |path| Dir[path.join('config', '**/*.yml')] }.flatten
    end

    # For each valid key, return an internal list of paths to search including all plugins
    # NOTE: Could include repositories
    def source_paths_map
      @source_paths_map ||= {
        cli: [plugin_root.gem_root],
        plugins: plugin_root.plugins.values.map { |p| p.plugin_lib.gem_root },
        project: [project_root],
        user: [user_root.join(config.name)]
      }
    end

    def require_minimum_deps
      with_timer('loading core dependencies') { require_relative 'cnfs/minimum_dependencies' }
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable %w[aws cnfs dns kubernetes postgres rails redis]
      end
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def load_config
      Config.env_separator = '_'
      Config.env_prefix = 'CNFS'
      Config.use_env = true
      ENV['CNFS_ENVIRONMENT'] = ENV.delete('CNFS_ENV')
      ENV['CNFS_NAMESPACE'] = ENV.delete('CNFS_NS')
      ENV['CNFS_REPOSITORY'] = ENV.delete('CNFS_REPO')
      @config = Config.load_files(plugin_root.gem_root.join(project_file), user_root.join('cnfs.yml'), project_file)
      Config.use_env = false
      config.debug ||= 0
    rescue StandardError => _e
      raise Cnfs::Error, "Error parsing config. Environment:\n#{`env | grep CNFS`}"
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def configure_logger
      @logger = TTY::Logger.new do |cfg|
        level = TTY::Logger::LOG_TYPES.keys.include?(config.logging.to_sym) ? config.logging.to_sym : :warn
        config.logging = cfg.level = level
      end
    end

    def initialize_development
      # require 'pry'
      # initialize_dev_plugins
    end

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
      Zeitwerk::Loader.default_logger = logger
      add_plugin_autoload_paths
      add_repository_autoload_paths
      autoload_dirs.each { |dir| loader.push_dir(dir) }
      loader.enable_reloading
      invoke_plugins_with(:before_loader_setup, loader)
      loader.setup
    end

    def reload
      reset
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
      @project_root ||= cwd.ascend { |path| break path if path.join(project_file).file? }
    end

    def paths
      @paths ||= config.paths.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
    end

    def autoload_all(path)
      return [] unless path.join('app').exist?

      path.join('app').children.select(&:directory?).select { |m| default_load_paths.include?(m.split.last.to_s) }
    end

    # Scan plugins for subdirs in <plugin_root>/app and add them to autoload_dirs
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def add_plugin_autoload_paths
      plugin_root.plugins.values.each do |plugin_class|
        next unless plugin_class.respond_to?(:plugin_lib) && (plugin = plugin_class.plugin_lib)

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
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def default_load_paths
      %w[controllers generators helpers models views]
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
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def setup_extensions
      # Ignore the extension points which are the controllers in the cli core gem
      logger.debug 'Loaded Extensions:'
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
            logger.info "#{klass} #{' ' * (40 - klass.to_s.size)} => #{extension_point}"
          end
        end
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def invoke_plugins_with(method, *options)
      plugins_responding_to(method).each do |plugin|
        options.empty? ? plugin.send(method) : plugin.send(method, options)
      end
    end

    def plugins_responding_to(method)
      plugin_root.plugins.values.append(plugin_root).select do |klass|
        klass.plugin_lib.respond_to?(method)
      end.collect(&:plugin_lib)
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
      @capabilities = nil
      Dir.chdir(project_root) { load_config }
    end

    def with_timer(title = '', level = :info)
      start_time = Time.now
      logger.send(level, "Start #{title} at #{start_time}")
      yield
      timers[title] = Time.now - start_time
      logger.send(level, "Completed #{title} in #{Time.now - start_time} seconds")
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

    def plugin_lib
      self
    end

    # rubocop:disable Metrics/MethodLength
    def set_capabilities
      cmd = TTY::Command.new(printer: :null)
      installed_tools = []
      missing_tools = []
      tools.each do |tool|
        if cmd.run!("which #{tool}").success?
          installed_tools.append(tool)
        else
          missing_tools.append(tool)
        end
      end
      Cnfs.logger.warn "Missing dependency tools: #{missing_tools.join(', ')}" if missing_tools.any?
      installed_tools
    end
    # rubocop:enable Metrics/MethodLength

    def tools
      Dependency.pluck(:name)
    end

    def platform
      os =
        case RbConfig::CONFIG['host_os']
        when /linux/
          'linux'
        when /darwin/
          'darwin'
        else
          'unknown'
        end
      ActiveSupport::StringInquirer.new(os)
    end

    def cli_mode
      @cli_mode ||= begin
        mode = config.dig(:cli, :dev) ? 'development' : 'production'
        ActiveSupport::StringInquirer.new(mode)
      end
    end

    def git
      return OpenStruct.new(sha: '', branch: '') unless system('git rev-parse --git-dir > /dev/null 2>&1')

      OpenStruct.new(
        tag: `git tag --points-at HEAD`.chomp,
        branch: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
        sha: `git rev-parse --short HEAD`.chomp
      )
    end

    # Cnfs.logger.compare_levels(:info, :debug) => :gt
    def silence_output(unless_logging_at = :debug)
      rs = $stdout
      $stdout = StringIO.new if logger.compare_levels(config.logging, unless_logging_at).eql?(:gt)
      yield
      $stdout = rs
    end

    def user_root
      @user_root ||= xdg.config_home.join('cnfs')
    end

    def user_data_root
      @user_data_root ||= xdg.data_home.join('cnfs')
    end

    def xdg
      @xdg ||= XDG::Environment.new
    end
  end
end
# rubocop:enable Metrics/ModuleLength
