# frozen_string_literal: true

module Services
  module AddConcern
    extend ActiveSupport::Concern

    included do |_base|
      attr_accessor :action

      private

      def action
        @action ||= :invoke
      end

      def generate(generator_type, arguments)
        unless (generator_class = "#{generator_type}/service_generator".classify.safe_constantize)
          raise Cnfs::Error, "#{generator_type} service generator class not found"
        end

        generator = generator_class.new(arguments, options.merge(services_file: services_file_path))
        generator.destination_root = repository_root
        generator.behavior = action
        generator.invoke_all
      end

      def services_file_path
        path = [options.environment, options.namespace].compact.join('/')
        Cnfs.project_root.join(Cnfs.paths.config, 'environments', path, 'services.yml')
      end

      def repository_root
        # TODO: Remove; It's not necessary
        @repository_root ||= options.repository ? Cnfs.paths.src.join(options.repository) : Cnfs.repository_root
      end
    end
  end
end
