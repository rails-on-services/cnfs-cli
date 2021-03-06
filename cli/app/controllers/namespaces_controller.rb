# frozen_string_literal: true

class NamespacesController < Thor
  include CommandHelper

  # Activate common options
  cnfs_class_options :environment
  cnfs_class_options :dry_run, :logging, :force
  # class_around :timer

  # map %w[i] => :infra
  # register InfraController, 'infra', 'infra [SUBCOMMAND]', 'Manage namespace infrastructure. (short-cut: i)'

  desc 'add NAME', 'Add namespace to environment configuration'
  before :initialize_project
  before :ensure_valid_project
  def add(name)
    execute({ name: name }, :crud, 2, :add)
  end

  desc 'list', 'Lists configured namespaces'
  before :initialize_project
  def list
    require 'tty-tree'
    puts TTY::Tree.new(Cnfs.paths.config.join('environments').to_s, only_dirs: true).render
    true
  end

  desc 'update NAME', 'Update namespace'
  def update(name)
    execute({ name: name }, :crud, 2, :update)
  end

  desc 'remove NAME', 'Remove namespace from environment configuration'
  map %w[rm] => :remove
  def remove(name)
    execute({ name: name, behavior: :revoke }, :crud, :remove)
  end

  # Deployment Manifests
  desc 'generate', 'Generate service manifests'
  cnfs_options :namespace
  option :clean, desc: 'Delete all existing manifests before generating',
                 aliases: '-c', type: :boolean
  before :initialize_project
  before :prepare_runtime
  def generate
    execute
  end

  # TODO: This should be a custom command
  # part of the services.yml mapping of a name to a command
  # then this runs a rake task which takes an option of display format
  # then remove all this code from the CNFS cli
  desc 'credentials', 'Display IAM credentials'
  cnfs_options :namespace
  option :format, desc: 'Options: sdk, cli, postman',
                  aliases: '-f', type: :string
  def credentials
    run(:credentials)
  end

  desc 'init', 'Initialize the namespace in the target environment'
  cnfs_options :namespace
  long_desc <<-DESC.gsub("\n", "\x5")

  Initializes the namespace in a K8s cluster, e.g. EKS, with services

  DESC
  def init
    run(:init)
  end

  # Cluster Runtime
  desc 'deploy', 'Deploy all services to namespace'
  cnfs_options :namespace
  before :initialize_project
  before :prepare_runtime
  # option :local, type: :boolean, aliases: '-l', desc: 'Deploy from local; default is via CI/CD'
  def deploy
    execute
  end

  desc 'destroy', 'Destory all services in the current namespace'
  cnfs_options :namespace, :force
  before :initialize_project
  before :prepare_runtime
  def destroy
    validate_destroy("\n#{'WARNING!!!  ' * 5}\nAbout to *permanently destroy* #{options.namespace} " \
                     "namespace in #{options.environment}\nDestroy cannot be undone!\n\nAre you sure?")
    execute
  end

  desc 'redeploy', 'Terminate and restart all services in namespace'
  cnfs_options :namespace, :force
  before :initialize_project
  before :prepare_runtime
  def redeploy
    validate_destroy("\nAbout to *restart* the #{options.namespace} " \
                     "namespace in #{options.environment}\nDestroy cannot be undone!\n\nAre you sure?")
    execute
  end

  desc 'status', 'Show services status'
  cnfs_options :namespace
  long_desc <<-DESC.gsub("\n", "\x5")

  Show the status of all services in the current namespace

  created, restarting, running, removing, paused, exited, or dead
  DESC
  def status(status = :running)
    run(:status, status: status)
  end
end
