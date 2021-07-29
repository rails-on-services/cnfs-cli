# frozen_string_literal: true

module Cnfs
  class Boot
    class << self
      # Boot the core framework
      def initialize!
        Cnfs.initialize!
        setup_top_level if Cnfs.cwd_outside_project?
        Dir.chdir(Cnfs.project_root) do
          load_config
          configure_logger
          require_minimum_deps
          yield
        end
      end

      def setup_top_level
        raise Cnfs::Error, "Invalid command '#{ARGV.join(' ')}'" unless Cnfs.valid_top_level_command?

        Cnfs.project_root = '.'
      end

      def run!
        Dir.chdir(Cnfs.project_root) do
          # yield :before_loader if block_given? # client's call to initialize_plugins
          # ActiveSupport::Notifications.instrument 'before_loader_setup.cnfs', { loader: loader }
          add_plugin_autoload_paths
          # add_repository_autoload_paths
          # ActiveSupport::Notifications.instrument 'before_loader_push_dir.cnfs'
          setup_class_loader
          setup_extensions
          yield # :after_loader if block_given? # client's call to cli
        end
        Cnfs.logger.info(Cnfs.timers.map { |k, v| "\n#{k}:#{' ' * (30 - k.length)}#{v.round(2)}" }.join)
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # TODO: use AS notifications and move to CLI
      def load_config
        Config.env_separator = '_'
        Config.env_prefix = 'CNFS'
        Config.use_env = true
        ENV['CNFS_ENVIRONMENT'] = ENV.delete('CNFS_ENV')
        ENV['CNFS_NAMESPACE'] = ENV.delete('CNFS_NS')
        ENV['CNFS_REPOSITORY'] = ENV.delete('CNFS_REPO')
        # binding.pry
        Cnfs.config = Config.load_files(Cnfs.config_paths)
        Config.use_env = false
        Cnfs.config.debug ||= 0
      rescue StandardError => _e
        raise Cnfs::Error, "Error parsing config. Environment:\n#{`env | grep CNFS`}"
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def configure_logger
        Cnfs.logger = TTY::Logger.new do |cfg|
          level = TTY::Logger::LOG_TYPES.keys.include?(Cnfs.config.logging.to_sym) ? Cnfs.config.logging.to_sym : :warn
          Cnfs.config.logging = cfg.level = level
        end
      end

      def require_minimum_deps
        Cnfs.with_timer('loading core dependencies') { require_relative 'minimum_dependencies' }
        # TODO: Refector to move to the appropriate gem using AS Notifications
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.uncountable %w[aws cnfs dns kubernetes postgres rails redis]
        end
      end

      # Zeitwerk based class loader methods
      def setup_class_loader
        Zeitwerk::Loader.default_logger = Cnfs.logger
        Cnfs.autoload_dirs.each { |dir| Cnfs.loader.push_dir(dir) }
        Cnfs.loader.enable_reloading
        ActiveSupport::Notifications.instrument 'before_loader_setup.cnfs', { loader: Cnfs.loader }
        Cnfs.loader.setup
      end

      # Scan plugins for subdirs in <plugin_root>/app and add them to autoload_dirs
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def add_plugin_autoload_paths
        Cnfs.plugin_root.plugins.values.each do |plugin_class|
          next unless (plugin = plugin_class.to_s.split('::').reject { |n| n.eql?('Plugins') }.join('::').safe_constantize)

          gem_load_paths = plugin.respond_to?(:load_paths) ? plugin.load_paths : %w[app]
          plugin_load_paths = plugin.respond_to?(:plugin_load_paths) ? plugin.plugin_load_paths : Cnfs.default_load_paths

          gem_load_paths.each do |load_path|
            load_path = plugin.gem_root.join(load_path)
            next unless load_path.exist?

            paths_to_load = load_path.children.select do |p|
              p.directory? && plugin_load_paths.include?(p.split.last.to_s)
            end
            Cnfs.autoload_dirs.concat(paths_to_load)
          end
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # Extensions found in autoload_dirs are configured to be loaded at a pre-defined extension point
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def setup_extensions
        # Ignore the extension points which are the controllers in the cli core gem
        Cnfs.logger.debug 'Loaded Extensions:'
        Cnfs.autoload_dirs.select { |p| p.split.last.to_s.eql?('controllers') }
            .reject { |p| p.join('../..').split.last.to_s.eql?('cli') }.each do |controllers_path|
          Dir.chdir(controllers_path) do
            Dir['**/*.rb'].each do |extension_path|
              extension = extension_path.delete_suffix('.rb')
              next unless (klass = extension.camelize.safe_constantize)

              namespace = extension.split('/').first
              extension_point = extension.delete_prefix("#{namespace}/").camelize
              Cnfs.extensions << Thor::CoreExt::HashWithIndifferentAccess.new(
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
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # Called from command helper
      def load_configuration(options)
        require_deps
        Cnfs.with_timer('loading project configuration') do
          Cnfs.config.merge!(options).merge!(options: options)
          Cnfs::Configuration.initialize!
          # Builder::Ansible.clone_repo
        end
      end

      # NOTE: keeping this separate for now as spec_helper invokes this manually
      # rather than initializing full project
      def require_deps
        Cnfs.with_timer('loading dependencies') { require_relative 'dependencies' }
      end
    end
  end
end
