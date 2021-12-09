# frozen_string_literal: true

class ResourcesController < Thor
  include Concerns::CommandController

  cnfs_class_options :dry_run, :init, :quiet, :generate
  cnfs_class_options CnfsCli.config.segments.keys

  desc 'add REPO COMPONENT RESOURCE', 'Add a resource configuration from a reposistory component to the specified segment'
  # TODO: This can be done interactively if the params are nil
  def add(repository, component, resource)
    execute(repository: repository, component: component, resource: resource, controller: :crud, method: :add)
  end

  desc 'create', 'Create a new resource configuration in the specified segment'
  def create = execute(controller: :crud, method: :create)

  desc 'list', 'List resources from the specified segment'
  map %w[ls] => :list
  def list = execute(controller: :crud, method: :list)

  desc 'show', 'Display resource details from the specified segment'
  def show(type = 'json') = execute(type: type, controller: :crud, method: :show)

  desc 'remove RESOURCE', 'Remove a resource configuration from the specified segment'
  def remove(resource) = execute(resource: resource, controller: :crud, method: :destroy)

  # TODO: These options are part of the Terrform controller concern
  # option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
  #                type: :boolean
  # option :init, desc: 'Force to download latest modules from TF registry',
  #               type: :boolean
  cnfs_options :force
  desc 'deploy', 'Deploy all resources for the specified segment'
  def deploy() = execute(controller: :provisioner, method: :create)

  desc 'connect RESOURCE', 'Connect to a resource in the specified segment'
  def connect(resource) = execute(resource: resource, controller: :provisioner, method: :connect)

  cnfs_options :force
  desc 'destroy', 'Destroy all resources for the specified segment'
  def destroy
    validate_destroy("\n#{'WARNING!!!  ' * 5}\nAbout to *permanently destroy* #{context.component.name} " \
                     "in #{context.component.owner&.name}\nDestroy cannot be undone!\n\nAre you sure?")
    execute(controller: :provisioner, method: :destroy)
  end
end
