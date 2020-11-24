# frozen_string_literal: true

class InfraController < Thor
  include CommandHelper

  # Activate common options
  cnfs_class_options :environment
  class_option :namespace, desc: 'Target namespace',
                           aliases: '-n', type: :string
  cnfs_class_options :quiet, :dry_run, :logging

  register Infra::AddController, 'add', 'add SUBCOMMAND [options]', 'Add a new infrastructure blueprint'
  # desc 'add PROVIDER NAME', 'Add a blueprint to the environment or namespace'

  desc 'remove PROVIDER NAME', 'Remove an infrastructure blueprint'
  def remove(provider, name)
    # Infra::AddRemoveController.new(options: options.merge(behavior: :revoke), arguments: { provider: provider, name: name }).execute
  end

  # TODO: Refactor commands
  desc 'generate', 'Generate target infrastructure'
  before :initialize_project
  before :prepare_runtime
  def generate(*_args)
    execute
  end

  desc 'plan', 'Show the terraform infrastructure plan'
  option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
                 type: :boolean
  option :init, desc: 'Force to download latest modules from TF registry',
                type: :boolean
  before :initialize_project
  before :prepare_runtime
  def plan(*args)
    execute(args: args)
  end

  desc 'apply', 'Apply the terraform infrastructure plan'
  option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
                 type: :boolean
  before :initialize_project
  before :prepare_runtime
  def apply(*args)
    execute(x_args: args)
  end

  # desc 'show', 'Show infrastructure details'
  # def show(type = 'json')
  #   Dir.chdir(infra.deploy_path) do
  #     show_json
  #   end
  # end

  desc 'destroy', 'Destroy infrastructure'
  def destroy
    execute
  end

  private

  # TODO: this needs to be per provider and region comes from deployment.yml
  def cmd_environment
    { 'AWS_DEFAULT_REGION' => 'ap-southeast-1' }
  end

  def config_files
    Dir["#{Ros.root.join(infra.deploy_path)}/*.tf"]
  end

  def generate_config
    silence_output do
      Ros::Be::Infra::Generator.new([], {}, behavior: :revoke).invoke_all
      Ros::Be::Infra::Generator.new.invoke_all
    end
  end
end
