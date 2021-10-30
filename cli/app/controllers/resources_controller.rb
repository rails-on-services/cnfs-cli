# frozen_string_literal: true

class ResourcesController < Thor
  include CommandHelper

  # Activate common options
  class_before :initialize_project
  cnfs_class_options :quiet, :dry_run, :logging
  cnfs_class_options Project.first.command_options_list

  # TODO: Refactor commands
  desc 'generate', 'Generate target infrastructure'
  def generate(*_args)
    Resources::CrudController
    execute
  end

  desc 'remove PROVIDER NAME', 'Remove an infrastructure blueprint'
  def remove(provider, name)
    Resources::CrudController
    # Infra::AddRemoveController.new(options: options.merge(behavior: :revoke), arguments: { provider: provider, name: name }).execute
  end

  desc 'sh SERVICE', 'Execute an interactive shell on a running service'
  cnfs_options Project.first.command_options_list
  # NOTE: shell is a reserved word in Thor so it can't be used
  def sh # (service)
    Resources::RuntimeController
    execute({ ip: 'admin@18.136.156.168' }, :shell)
  end

  desc 'plan', 'Show the terraform infrastructure plan'
  option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
                 type: :boolean
  option :init, desc: 'Force to download latest modules from TF registry',
                type: :boolean
  def plan(*args)
    Resources::BuilderController
    execute(args: args)
  end

  desc 'apply', 'Apply the terraform infrastructure plan'
  option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
                 type: :boolean
  def apply(*args)
    Resources::BuilderController
    execute(x_args: args)
  end

  desc 'destroy', 'Destroy infrastructure'
  cnfs_options :force
  def destroy
    validate_destroy("\n#{'WARNING!!!  ' * 5}\nAbout to *permanently destroy* #{options.namespace} " \
                     "namespace in #{options.environment}\nDestroy cannot be undone!\n\nAre you sure?")
    Resources::BuilderController
    # execute
  end

  # desc 'show', 'Show infrastructure details'
  # def show(type = 'json')
  #   Dir.chdir(infra.deploy_path) do
  #     show_json
  #   end
  # end
end
