# frozen_string_literal: true

module Primary
  class NamespaceController < InfraController

    # Cluster Admin
    # desc 'create NAMESPACE', 'Create a new NAMESPACE'
    desc 'create', 'Provision the namespace in the environment'
    # NOTE: this creates the namespace in the cluster; To add a new namespace that is the add command
    def create
      run(:create)
    end

    desc 'destroy', 'Remove namespace from current environment'
    option :force, desc: 'Do not prompt for confirmation', type: :boolean
    # TODO: Test this by taking down a compose cluster
    def destroy
      return unless options.force || yes?("\n#{'WARNING!!!  ' * 5}\nAbout to *permanently destroy* #{options.namespace} " \
                                        "namespace in #{options.environment}\nDestroy cannot be undone!\n\nAre you sure?")
      run(:destroy)
    end

    # Cluster Runtime
    desc 'deploy', 'Deploy all services to namespace'
    # option :local, type: :boolean, aliases: '-l', desc: 'Deploy from local; default is via CI/CD'
    def deploy(*services)
      services = Service.pluck(:name) if services.empty?
      run(:deploy, services: services)
    end

    desc 'redeploy', 'Create and Start all services in namespace'
    option :force, desc: 'Do not prompt for confirmation', type: :boolean
    # TODO: validate that supplied services are correct and fail if they are not
    def redeploy(*services)
      services = Service.pluck(:name) if services.empty?
      return unless options.force || yes?("\nAbout to *restart* #{services.join(' ')} \n\nAre you sure?")

      run(:redeploy, services: services)
    end
  end
end
