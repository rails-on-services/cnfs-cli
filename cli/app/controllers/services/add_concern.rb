# frozen_string_literal: true

module Services
  module AddConcern
    extend ActiveSupport::Concern

    included do |base|
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
        @repository_root ||= options.repository ? Cnfs.paths.src.join(options.repository) : Cnfs.repository_root
      end
    end
  end
end

=begin
    # def hash
    #   hash = repo ? options_string_to_hash(repo.options) : {}
    #   hash.merge!(options_string_to_hash(options.options || ''))
    #   hash.merge!(type: options.type)
    #   hash.merge!(repository_root: repository_root)
    #   hash.merge!(services_file: Cnfs.project_root.join(Cnfs.paths.config, 'environments', options.environment || '', options.namespace || '', 'services.yml'))
    # end

    # def repo
    #   @repo ||= set_repo
    # end

    # def set_repo
    #   Cnfs.require_deps
    #   Cnfs.require_project!(arguments: arguments, options: options, response: nil)
    #   repository_name = repository_root.split.last.to_s

    #   unless (repo = Repository.find_by(name: repository_name))
    #     raise Cnfs::Error, "Repository #{repository_name} not found"
    #   end
    #   repo
    # end

    # def options_string_to_hash(string)
    #   string.split(',').each_with_object({}) { |s, h| k, v = s.split('='); h[k] = v }
    # end
=end
