# frozen_string_literal: true

module Projects
  class ConsoleController
    include ExecHelper

    def execute
      require 'pry'
      Pry.start(self, prompt: proc { |_obj, _nest_level, _| 'cnfs> ' })
    end

    class << self
      def shortcuts
        return {} unless defined?(ActiveRecord)

        { b: Blueprint, e: Environment, k: Key, n: Namespace, p: Provider, r: Repository, s: Service, u: User }
      end
    end

    shortcuts.each_pair do |key, klass|
      define_method(key) { klass } unless %w[p r].include?(key)
      define_method("#{key}a") { klass.all }
      define_method("#{key}f") { cache["#{key}f"] ||= klass.first }
      define_method("#{key}l") { cache["#{key}l"] ||= klass.last }
      define_method("#{key}p") { |*attributes| klass.pluck(*attributes) }
      define_method("#{key}fb") { |name| klass.find_by(name: name) }
    end

    def cache
      @cache ||= {}
    end

    def reset_cache
      @cache = nil
    end

    def reload!
      reset_cache
      Cnfs.reload
      true
    end

    def r; reload! end

    def m; project.manifest end

    def o
      options
    end

    def oa(opts = {})
      options.merge!(opts)
    end

    def od(key)
      @options = Thor::CoreExt::HashWithIndifferentAccess.new(options.except(key.to_s))
      options
    end

    def cmd
      OpenStruct.new({
        projects: ProjectsController.new(args, options),
        repositories: RepositoriesController.new(args, options),
        environments: EnvironmentsController.new(args, options),
        namespaces: NamespacesController.new(args, options),
        images: ImagesController.new(args, options),
        services: ServicesController.new(args, options)
      })
    end
  end
end
