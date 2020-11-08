# frozen_string_literal: true

module Primary
  class NewController
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    def execute
      generator = NewGenerator.new([name], options)
      generator.destination_root = name
      generator.invoke_all

      Dir.chdir(name) do
        Cnfs.reset
        add_environments
        add_backend if options.backend
        add_cnfs if options.cnfs
      end
    end

    def add_environments
      %w[development staging production].each do |env|
        ComponentController.new([], options.merge(project_name: name)).environment(env)
        ComponentController.new([], options.merge(project_name: name, environment: env)).namespace('main')
      end
    end

    def add_backend
      add_backend_development_services
      add_backend_services
    end

    def add_cnfs
      add_backend_development_services unless options.backend
      add_cnfs
    end

    # Add typical services to the development environment
    def add_backend_development_services
      sc = Component::ServiceController.new([], options.merge(environment: 'development'))
      sc.localstack
      sc.nginx
      sc.postgres
      sc.redis
      sc.wait
    end

    def add_backend_services
      Component::RepositoryController.new([], options).rails(this_repo)
      # Add typical CNFS services to the project
      opts = options.cnfs ? { gem_source: cnfs_repo } : {}
      %w[iam cognito].each do |service|
        Component::ServiceController.new([], options.merge(opts).merge(gem: "cnfs-#{service}")).rails(service)
      end
    end

    def add_cnfs
      env = 'development'
      ns = 'cnfs'
      ComponentController.new([], options.merge(project_name: name, environment: env)).namespace(ns)
      # Component::RepositoryController.new([], options).url(cnfs_repo)
      # Add all CNFS service configurations to the project
      sc = Component::ServiceController.new([], options.merge(environment: env, namespace: ns))
      %w[iam cognito].each do |service|
        sc.rails(service)
      end
    end

    def this_repo; 'backend' end
    def cnfs_repo; 'cnfs' end
  end
end
