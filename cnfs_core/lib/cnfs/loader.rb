# frozen_string_literal: true

module Cnfs
  class Loader
    attr_accessor :loader

    def initialize(logger: nil)
      @loader = Zeitwerk::Loader.new
      loader.logger = logger if logger
    end

    # Zeitwerk loader methods
    def setup
      autoload_dirs.each { |dir| loader.push_dir(dir) }
      loader.enable_reloading
      loader.setup
    end

    def autoload(mode: nil, paths: [])
      paths.each { |path| autoload_all(path) }
    end

    def autoload_dirs
      @autoload_dirs ||= []
    end

    def autoload_all(path)
      return [] unless path.join('app').exist?

      dirs = path.join('app').children.select(&:directory?).select { |m| default_load_paths.include?(m.split.last.to_s) }
      autoload_dirs.concat(dirs)
      dirs
    end

    def default_load_paths
      %w[controllers generators helpers models views]
    end

    def add_plugin_autoload_paths(values)
      values.each do |plugin_class|
        next unless (plugin = plugin_class.to_s.split('::').reject { |n| n.eql?('Plugins') }.join('::').safe_constantize)

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

      # TODO: Refactor this to include strategy
      # Scan plugins for subdirs in <plugin_root>/app and add them to autoload_dirs
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # Extensions found in autoload_dirs are configured to be loaded at a pre-defined extension point
      def setup_extensions
        # Ignore the extension points which are the controllers in the cli core gem
        Cnfs.logger.debug 'Loaded Extensions:'
        autoload_dirs.select { |p| p.split.last.to_s.eql?('controllers') }
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

    def reload
      loader.reload
    end
  end
end
