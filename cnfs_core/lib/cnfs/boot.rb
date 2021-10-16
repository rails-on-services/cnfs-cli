# frozen_string_literal: true

module Cnfs
  class Boot
    class << self
      # Boot the core framework
      def run!
        Cnfs.loader.autoload_all(Cnfs.gem_root)
        Cnfs.loader.add_plugin_autoload_paths(Cnfs.plugin_root.plugins.values)
        Cnfs.loader.setup
        Cnfs.data_store.add_models(Cnfs.schema_model_names)
        Cnfs.data_store.setup
        setup_extensions
        yield
        Cnfs.logger.info(Cnfs.timers.map { |k, v| "\n#{k}:#{' ' * (30 - k.length)}#{v.round(2)}" }.join)
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
        Cnfs.loader.autoload_dirs.select { |p| p.split.last.to_s.eql?('controllers') }
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
    end
  end
end
