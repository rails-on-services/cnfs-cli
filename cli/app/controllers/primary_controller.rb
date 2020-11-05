# frozen_string_literal: true

class PrimaryController < CommandsController
  Cnfs.controllers.each do |controller|
    controller = OpenStruct.new(controller)
    register controller.klass.safe_constantize, controller.title, controller.help, controller.description
  end

  register ComponentAddController, 'add', 'add COMPONENT [options]', 'Add a project component' #: blueprint, environment, namespace, repository or service'
  map %w[rm] => :remove
  register ComponentRemoveController, 'remove', 'remove COMPONENT NAME', 'Remove a project component' # : environment, namespace, repository or service. (short-cut: rm)'

  register ConfigController, 'config', 'config SUBCOMMAND', 'Get and set project configuration values'
  map %w[ls] => :list
  register ListController, 'list', 'list COMPONENT', 'List configuration objects (short-cut: ls)'

  map %w[i] => :infra
  register InfraController, 'infra', 'infra SUBCOMMAND [options]', 'Manage target infrastructure: k8s clusters, storage, etc'

  def self.exit_on_failure?
    true
  end

  unless %w[dev new version].include?(ARGV[0])
    class_option :environment, desc: 'Target environment',
      aliases: '-e', type: :string, required: true, default: Cnfs.config.environment
    class_option :namespace, desc: 'Target namespace',
      aliases: '-n', type: :string, required: true, default: Cnfs.config.namespace
    class_option :fail_fast,  desc: 'Skip any remaining commands after a command fails',
      aliases: '--ff', type: :boolean
  end

  class_option :debug, desc: 'Display deugging information with degree of verbosity',
    aliases: '-d', type: :numeric, default: Cnfs.config.debug
  # class_option :help, desc: 'Display usage information',
  #   aliases: '-h', type: :boolean
  class_option :noop, desc: 'Do not execute commands',
    type: :boolean, default: Cnfs.config.noop
  class_option :quiet, desc: 'Suppress status output',
    aliases: '-q', type: :boolean, default: Cnfs.config.quiet
  # class_option :tag, type: :string
  class_option :verbose, desc: 'Display extra information from command',
    aliases: '-v', type: :boolean, default: Cnfs.config.verbose

  desc 'dev', 'A placeholder command for development of new commands'
  def dev
    # binding.pry
    run(:dev)
  end

  # Project Management
  desc 'new NAME', 'Create a new CNFS project'
  option :force, desc: 'Force creation even if project aready exists',
    aliases: '-f', type: :boolean
  # option :backend, desc: 'Generate the CNFS Backend Core Repository and Services',
  #   aliases: '-b', type: :boolean
  # option :dev, desc: 'Clone CNFS repositories for local development',
  #   type: :boolean
  def new(name)
    if Dir.exist?(name)
      if options.force || yes?('Directory already exists. Destroy and recreate?')
        FileUtils.rm_rf(name)
      else
        raise Cnfs::Error, set_color('Directory exists. exiting.', :red)
      end
    end
    NewController.new(name, options).execute
  end

  desc 'init', 'Initialize the CNFS project: clone configured repositories; check for dependencies'
  option :customize, desc: 'Copy generators from gem to project',
    aliases: '-c', type: :boolean
  def init
    run(:init)
  end

  # TODO: This is like Amplify status
  # desc 'list', 'List configuration objects: config, environments, namespaces, repositories, services and blueprints'
  # option :show_enabled, type: :boolean, aliases: '--enabled', desc: 'Only show services enabled in current config file'
  # map %w[ls] => :list
  # def list(*filters)
  #   run(:list, filters: filters)
  # end

  # Deployment Manifests
  desc 'generate', 'Generate manifests for application deployment'
  option :clean, desc: 'Delete all existing manifests before generating',
    aliases: '-c', type: :boolean
  def generate
    run(:generate)
  end

  desc 'show', 'Show service manifest'
  option :modifier,  desc: "A suffix applied to service name, e.g. '.env'",
    aliases: '-m', type: :string
  def show(*services)
    run(:show, services: services)
  end

  # Image Opertions
  desc 'build SERVICES', 'Build all or specific service images'
  # NOTE: build and connect is really only valid for local otherwise need to deploy first
  option :shell, desc: 'Connect to service shell after building',
    aliases: '--sh', type: :boolean
  # TODO: Take an environment for which to build; target is just infra like a k8s cluster
  # application is just the colleciton of services; namespace is where it's deployed
  # so namespace would declare the environment, e.g. production, etc
  # def build(namespace_name, *service_names)
  # TODO: Things like the image naming convention should be part of the service.config with a store accessor
  # so that each image and within an environment/namespace _could_ have its own naming pattern
  option :all,
    aliases: '-a', type: :boolean
  def build(*services)
    run(:build, services: services, service: services.last)
  end

  desc 'test SERVICES', 'Run test commands on service(s)'
  option :build, desc: 'Build image before testing',
    aliases: '-b', type: :boolean
  option :fail_all, desc: 'Skip any remaining services after a test fails',
    aliases: '--fa', type: :boolean
  option :fail_fast, desc: 'Skip any remaining tests for a service after a test fails',
    aliases: '--ff', type: :boolean
  option :push, desc: 'Push image after successful testing',
    aliases: '-p', type: :boolean
  # TODO: How to handle service names?
  def test(*args)
    run(:test, args)
  end

  desc 'push IMAGES', 'Push one or all images'
  def push(*services)
    run(:push, services: services)
  end

  desc 'pull IMAGES', 'Pull one or all images'
  def pull(*services)
    run(:pull, services: services)
  end

  desc 'publish', 'Publish API documentation to Postman'
  option :force, desc: 'Force generation of new documentation',
    aliases: '-f', type: :boolean
  # TODO: refactor
  # Maybe in the service configuration is an attribute commands which is an array of hashes:
  # { command: 'publish erd', exec: 'rails g erd' }
  # Maybe publish is not a full command but there is a command method which then parses the array of hashes
  # In that case test could be put into this array as well
  def publish(type, *_services)
    raise Cnfs::Error, set_color("types are 'postman' and 'erd'", :red) unless %w[postman erd].include?(type)
  end

  # Cluster Admin
  desc 'create NAMESPACE', 'Create a new NAMESPACE'
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
  desc 'deploy', 'Deploy services to NAMESPACE in target ENVIRONMENT'
  # option :local, type: :boolean, aliases: '-l', desc: 'Deploy from local; default is via CI/CD'
  def deploy(*services)
    services = Service.pluck(:name) if services.empty?
    run(:deploy, services: services)
  end

  desc 'redeploy', 'Create and Start'
  option :force, desc: 'Do not prompt for confirmation', type: :boolean
  # TODO: validate that supplied services are correct and fail if they are not
  def redeploy(*services)
    services = Service.pluck(:name) if services.empty?
    return unless options.force || yes?("\nAbout to *restart* #{services.join(' ')} \n\nAre you sure?")

    run(:redeploy, services: services)
  end

  desc 'ps', 'List running services'
  option :format, desc: '',
    type: :string, aliases: '-f'
  option :status, desc: 'created, restarting, running, removing, paused, exited, or dead',
    type: :string
  def ps # (*args)
    binding.pry
    run(:ps) # , args: args)
  end

  desc 'status', 'Show platform services status: created, restarting, running, removing, paused, exited, or dead'
  def status(status = :running)
    run(:status, status: status)
  end

  # Service Admin
  desc 'start', 'Start one or more services (short-cut: s)'
  option :attach, desc: 'Attach to service after starting',
    aliases: '-a', type: :boolean
  # option :build, type: :boolean, aliases: '-b', desc: 'Build image before run'
  # option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
  # option :console, type: :boolean, aliases: '-c', desc: "Connect to service's rails console after starting"
  # option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
  option :profiles, desc: 'List of profiles to start',
    aliases: '-p', type: :array
  # option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  option :shell, desc: 'Connect to service shell after starting',
    aliases: '--sh', type: :boolean
  # TODO: Take a profile array also. The config should define a default profile
  map %w[s] => :start
  def start(*services)
    run(:start, services: services)
  end

  desc 'restart SERVICE', 'Stop and start one or more services'
  # TODO: When taking array of services but attach only uses the last one
  # Add default: '' so if -a is passed and value is blank then it's the last one
  option :attach, desc: 'Attach to service after executing command',
    aliases: '-a', type: :boolean
  option :build, desc: 'Build image before executing command',
    aliases: '-b', type: :boolean
  # NOTE: Seed the database before executing command
  option :clean, desc: 'Perform a clean restart equivalent to terminate and start',
    aliases: '--clean', type: :boolean
  option :profiles, desc: 'List of profiles to start',
    aliases: '-p', type: :array
  # option :console, type: :boolean, aliases: '-c', desc: 'Connect to service console after executing command'
  # option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
  # option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  # option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after executing command'
  def restart(*services)
    run(:restart, services: services)
  end

  desc 'stop SERVICE', 'Stop one or more services'
  option :profiles, desc: 'List of profiles to stop',
    aliases: '-p', type: :array
  def stop(*services)
    run(:stop, services: services)
  end

  desc 'terminate SERVICE', 'Terminate one or more services'
  option :profiles, desc: 'List of profiles to terminate',
    aliases: '-p', type: :array
  def terminate(*services)
    run(:terminate, services: services)
  end

  # Service Runtime
  desc 'attach SERVICE', 'Attach to a running service; ctrl-f to detach; ctrl-c to stop/kill the service (short-cut: a)'
  map %w[a] => :attach
  option :build, desc: 'Build image before executing command',
    aliases: '-b', type: :boolean
  option :profile, desc: 'Service profiles',
    aliases: '-p', type: :string
  def attach(service)
    run(:attach, service: service)
  end

  # NOTE: This is a test to run a command with multiple arguments; different from exec
  # desc 'command COMMAND', 'Run specified command on a service'
  # map %w[cmd] => :command
  # def command(service, *args)
  #   run(:command, service: service, command: args)
  # end

  desc 'console [SERVICE]', 'Start a cnfs or service console (short-cut: c)'
  map %w[c] => :console
  def console(service = nil)
    service ? run(:console, service: service) : run(:console)
  end

  desc 'copy SRC DEST', 'Copy a file to or from a running service'
  map %w[cp] => :copy
  def copy(src, dest)
    run(:copy, src: src, dest: dest)
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

  desc 'exec SERVICE COMMAND', 'Execute a command on a running service'
  def exec(service, *command_args)
    run(:exec, service: service, command_args: command_args)
  end

  desc 'logs', 'Tail logs of a running service'
  option :tail, aliases: '-f', type: :boolean
  def logs(service)
    run(:logs, service: service)
  end

  desc 'sh SERVICE', 'Execute an interactive shell on a service'
  option :build, desc: 'Build image before executing shell',
    aliases: '-b', type: :boolean
  # NOTE: shell is a reserved word in Thor so it can't be used
  def sh(service)
    arguments = { service: service }
    arguments.merge!(services: [service]) if options.build
    run(:shell, arguments)
  end

  # Utility
  desc 'version', 'Show cnfs version'
  def version
    puts "v#{Cnfs::VERSION}"
  end

  # desc 'up SERVICE', 'bring up service(s)'
  # option :attach, type: :boolean, aliases: '-a', desc: 'Attach to service after starting'
  # option :build, type: :boolean, aliases: '-b', desc: 'Build image before run'
  # option :console, type: :boolean, aliases: '-c', desc: "Connect to service's rails console after starting"
  # option :daemon, type: :boolean, aliases: '-d', desc: 'Run in the background'
  # option :force, type: :boolean, default: false, aliases: '-f', desc: 'Force cluster creation'
  # option :profile, type: :string, aliases: '-p', desc: 'Service profile to bring up'
  # option :replicas, type: :numeric, aliases: '-r', desc: 'Number of containers (instance) or pods (kubernetes) to run'
  # option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  # option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after starting'
  # option :skip, type: :boolean, aliases: '--skip', desc: 'Skip starting services (just initialize cluster)'
  # option :skip_infra, type: :boolean, aliases: '--skip-infra', desc: 'Skip deploy infra services'
  # def up(*services)
  #   command = context(options)
  #   command.up(services)
  #   command.exit
  # end
end
