# frozen_string_literal: true

module Component
  class ServiceController < ApplicationController
    attr_accessor :options, :arguments

    def initialize(options:, arguments:)
      @options = options
      @arguments = arguments
    end

    def add
      unless (generator_class = "#{options.repository_type}/service_generator".classify.safe_constantize)
        raise Cnfs::Error, "#{options.repository_type} service generator class not found"
      end

      # generator = generator_class.new([arguments.name], options.except('options').merge(hash))
      generator = generator_class.new([arguments.name], options.merge(hash))
      generator.destination_root = repository_root
      generator.behavior = arguments.action
      generator.invoke_all
    end

    def remove
      add
    end

    def hash
      path = [options.environment, options.namespace].compact.join('/')
      path = Cnfs.project_root.join(Cnfs.paths.config, 'environments', path, 'services.yml')
      { services_file: path }
    end

    def repository_root
      @repository_root ||= options.repository ? Cnfs.paths.src.join(options.repository) : Cnfs.repository_root
    end
  end
end

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

  # def xyz
  #   return unless action.eql?(:invoke) and options.target

  #   raise Cnfs::Error, set_color('invalid target', :red) unless Dir.exist?(Cnfs.paths.src.join(options.target))

  #   target_application_path = Cnfs.paths.src.join(name, 'services')
  #   services = target_application_path.children.select { |c| c.directory? }
  #   services.each do |source_path|
  #     service_name = source_path.split.last.to_s
  #     target_path = source_path.to_s.gsub(name, options.target)
  #     raise Cnfs::Error, set_color('service exists', :red) if Dir.exist?(target_path)

  #     # TODO: Generate a service as an app
  #     # next unless (generator_class = "#{options.type}/service_generator".classify.safe_constantize)
  #     next unless (generator_class = "rails/cnfs/service_generator".classify.safe_constantize)

  #     generator = generator_class.new([service_name], options)
  #     generator.destination_root = Cnfs.paths.src.join(options.target)
  #     generator.behavior = action
  #     generator.invoke_all
  #   end
  # end
