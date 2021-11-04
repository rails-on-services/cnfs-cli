# frozen_string_literal: true

class ResourcesController < Thor
  include CommandHelper

  # Activate common options
  cnfs_class_options :quiet, :dry_run, :logging
  cnfs_class_options CnfsCli.configuration.command_options_list

  desc 'add', 'Add a resource by name from a charts repo or interactively to a component (current context)'
  def add(resource)
    execute(resource: resource, controller: :crud, method: :create)
  end

  desc 'list', 'Lists services configured in the current context'
  map %w[ls] => :list
  def list
    puts context.resources.pluck(:name).join("\n")
  end


  # desc 'show', 'Show infrastructure details'
  # def show(type = 'json')
  #   Dir.chdir(infra.deploy_path) do
  #     show_json
  #   end
  # end

  desc 'remove RESOURCE', 'Remove resource from the specified component'
  def remove(resource)
    execute(resource: resource, controller: :crud, method: :delete)
  end

  # Builder commands
  desc 'create', 'Create infrastructure'
  option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
                 type: :boolean
  option :init, desc: 'Force to download latest modules from TF registry',
                type: :boolean
  # TODO: Add 'auto' option which means don't confirm TF build, just do it
  def create(resource)
    execute(resource: resource, controller: :builder, method: :create)
  end

  desc 'destroy', 'Destroy infrastructure'
  cnfs_options :force
  def destroy(resource)
    validate_destroy("\n#{'WARNING!!!  ' * 5}\nAbout to *permanently destroy* #{options.namespace} " \
                     "namespace in #{options.environment}\nDestroy cannot be undone!\n\nAre you sure?")
    execute(resource: resource, controller: :builder, method: :destroy)
  end

  # Runtime commands
  desc 'connect RESOURCE', 'Connext to a running resource'
  cnfs_options CnfsCli.configuration.command_options_list
  # NOTE: shell is a reserved word in Thor so it can't be used
  def connect(resource)
    execute(ip: 'admin@18.136.156.168', controller: :runtime, method: :connect)
  end
end
