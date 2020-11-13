# frozen_string_literal: true

class NamespacesController < CommandsController
  OPTS = %i[env ns noop quiet verbose]
  include Cnfs::Options

  register InfraController, 'infra', 'infra [SUBCOMMAND]', 'Manage namespace infrastructure'

  desc 'list', 'Lists configured namespaces'
  def list
    Cnfs.paths.config.join('environments').children.select{ |e| e.directory? }.each do |path|
      puts path.children.select{ |e| e.directory? }.map(&:to_s)
    end
  end

  # Deployment Manifests
  desc 'generate', 'Generate service manifests'
  option :clean, desc: 'Delete all existing manifests before generating',
    aliases: '-c', type: :boolean
  def generate
    run(:generate)
  end

  # TODO: This should be a custom command
  # part of the services.yml mapping of a name to a command
  # then this runs a rake task which takes an option of display format
  # then remove all this code from the CNFS cli
  desc 'credentials', 'Display IAM credentials'
  option :format, desc: 'Options: sdk, cli, postman',
    aliases: '-f', type: :string
  def credentials
    run(:credentials)
  end

  desc 'create', 'Provision the namespace in the environment'
  def create
    run(:create)
  end

  desc 'destroy', 'Remove namespace from current environment'
  option :force, desc: 'Do not prompt for confirmation',
    type: :boolean
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

  desc 'redeploy', 'Terminate and restart all services in namespace'
  option :force, desc: 'Do not prompt for confirmation',
    type: :boolean
  # TODO: validate that supplied services are correct and fail if they are not
  def redeploy(*services)
    services = Service.pluck(:name) if services.empty?
    return unless options.force || yes?("\nAbout to *restart* #{services.join(' ')} \n\nAre you sure?")

    run(:redeploy, services: services)
  end

  desc 'status', 'Show services status'
  long_desc <<-DESC.gsub("\n", "\x5")

  Show the status of all services in the current namespace

  created, restarting, running, removing, paused, exited, or dead
  DESC
  def status(status = :running)
    run(:status, status: status)
  end
end
