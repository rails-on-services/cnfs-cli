# frozen_string_literal: true

# Convenience methods to add conventional configurations to a new project
# Backend: 
module Project
  class AddController < Thor

    desc 'backend', 'Add backend package to the project'
    # option :backend, desc: 'Create the project with a set of typical backend services',
    #   aliases: '-b', type: :boolean
    option :cnfs, desc: 'Create CNFS service configurations for development mode',
      type: :boolean
    def backend
      # add_backend_development_services
      # add_backend_repository_and_cnfs_services
    end

    desc 'development', 'Customize project for CNFS development'
    def development
      # add_backend_development_services
      add_cnfs_backend_development_services
    end

    private

    # Add typical services to the development environment
    def add_backend_development_services
      sc = Services::AddController.new([], options.merge(environment: 'development'))
      sc.localstack
      sc.nginx
      sc.postgres
      sc.redis
      sc.wait
    end

    # NOTE: To be refactored
    def add_backend_repository_and_cnfs_services
      Repositories::NewController.new([], options).rails(this_repo)
      # Add typical CNFS services to the project
      opts = options.cnfs ? { gem_source: cnfs_repo } : {}
      %w[iam cognito].each do |service|
        Component::ServiceController.new([], options.merge(opts).merge(gem: "cnfs-#{service}")).rails(service)
      end
    end

    def add_cnfs_backend_development_services
      # name = 'cnfs'
      # env = 'development'
      # ns = 'cnfs'
      # Namespaces::AddController.new([], options.merge(project_name: name, environment: env)).namespace(ns)
      RepositoriesController.new([], options).add(cnfs_repo)
      # Add all CNFS service configurations to the project
      # ServicesController.new([], options).rails('hmmm')
      # # if not env and no ns then services are created at project scope
      # # This could say to backend/rails service generator to just copy over some service file
      # sc = Services::AddController.new([], options.merge(environment: env, namespace: ns))
      # %w[iam cognito].each do |service|
      #   sc.rails(service)
      # end
    end

    def this_repo; 'backend' end
    def cnfs_repo; 'cnfs' end
  end
end
