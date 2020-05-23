# frozen_string_literal: true

class PrimaryController < CommandsController
  Cnfs.controllers.each do |controller|
    controller = OpenStruct.new(controller)
    register controller.klass.safe_constantize, controller.title, controller.help, controller.description
  end

  def self.exit_on_failure?
    true
  end

  class_option :debug, type: :numeric, aliases: '-d'
  class_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
  class_option :noop, type: :boolean, aliases: '--no'
  class_option :quiet, type: :boolean, aliases: '-q'
  class_option :verbose, type: :boolean, aliases: '-v'

  class_option :context_name, type: :string, default: 'default', aliases: '-c', desc: 'The context in which to run the command'
  # class_option :key_name, type: :string, aliases: '-k'
  # class_option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  # class_option :namespace_name, type: :string, aliases: '-n'
  # class_option :application_name, type: :string, aliases: '-a'
  # class_option :service_names, type: :array, aliases: '-s'
  # class_option :profile_names, type: :array, aliases: '-p'
  # class_option :tag_names, type: :array, aliases: '--tags'


  # Application Management
  desc 'new TYPE NAME', 'Create a new CNFS application of TYPE backend, frontend or pipeline with name NAME'
  def new(type, name)
    "#{type.classify}::NewController".safe_constantize&.new(name, options)&.execute
    InitController.new(name, options.merge(type: type.to_sym)).execute
  end

  desc 'init TYPE NAME', 'Initialize the application in current directory with name NAME'
  def init(type, name)
    InitController.new(name, options.merge(type: type.to_sym, init: true)).execute
  end

  # desc 'init APPLICATION', 'Initialize an application'
  # def init(application_name)
  #   run(:init, application_name: application_name)
  # end

  desc 'add TYPE NAME', 'Add a new component to the CNFS application'
  def add(type, name)
    application_type = Cnfs.application.config.type
    "#{application_type.classify}::AddController".safe_constantize&.new(type, name, options)&.execute
  end

  desc 'remove TYPE NAME', 'Remove a component from the CNFS application'
  def remove(type, name)
    application_type = Cnfs.application.config.type
    "#{application_type.classify}::AddController".safe_constantize&.new(type, name, options.merge(revoke: true))&.execute
  end

  desc 'list', 'List configuration objects: config, ns, contexts, deployments, applications'
  option :show_enabled, type: :boolean, aliases: '--enabled', desc: 'Only show services enabled in current config file'
  map %w[ls] => :list
  def list(what = :config)
    run(:list, what: what)
  end


  # Deployment Manifests
  desc 'generate', 'Generate manifests for application deployment'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  # option :deployment_name, type: :string, aliases: '-d'
  option :clean, type: :boolean, desc: 'Remove existing manifests before generating'
  def generate # (deployment_name)
    run(:generate) # , deployment_name: deployment_name)
  end

  desc 'show', 'Show service manifest'
  # option :service_names, type: :array, aliases: '-s'
  option :modifier, type: :string, aliases: '-m'
  def show(deployment_name, *service_names)
    run(:show, deployment_name: deployment_name, service_names: service_names)
  end


  # Image Opertions
  desc 'build NAMESPACE [SERVICES]', 'Build all or specific application images'
  option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after building'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure to locate the namespace'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  option :service_name, type: :string, aliases: '-s'
  # option :service_names, type: :array, aliases: '-s'
  # TODO: Take an environment for which to build; target is just infra like a k8s cluster
  # application is just the colleciton of services; namespace is where it's deployed
  # so namespace would declare the environment, e.g. production, etc
  # def build(namespace_name, *service_names)
  def build(*args)
  # def build(n = @context&.namespace&.name)
    # binding.pry
    run(:build, args) # namespace_name: namespace_name, service_names: service_names)
  end

  # def initialize(one, cli_args, three)
  #   context_name = cli_args.index('-c') ? cli_args[cli_args.index('-c') +1] : nil
  #   # binding.pry
  #   @context = Context.find_by(name: context_name)
  #   super
  # end

  desc 'test IMAGE', 'Run tests on image(s)'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before testing'
  option :fail_all, type: :boolean, aliases: '--fa', desc: 'Skip any remaining services after a test fails'
  option :fail_fast, type: :boolean, aliases: '--ff', desc: 'Skip any remaining tests for a service after a test fails'
  option :push, type: :boolean, desc: 'Push image after successful testing'
  def test(*args)
    run(:test, args)
  end

  desc 'push IMAGE', 'Push one or all images'
  # TODO: refactor
  def push(*args)
    run(:push, args)
  end

  desc 'pull IMAGE', 'Pull one or all images'
  # TODO: refactor
  def pull(*args)
    run(:pull, args)
  end

  desc 'publish', 'Publish API documentation to Postman'
  option :force, type: :boolean, aliases: '-f', desc: 'Force generation of new documentation'
  # TODO: refactor
  def publish(type, *_services)
    raise Error, set_color("types are 'postman' and 'erd'", :red) unless %w[postman erd].include?(type)
  end


  # Cluster Admin
  desc 'create TARGET NAMESPACE', 'Create a new NAMESPACE in TARGET'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure to locate the namespace'
  option :namespace_name, type: :string, aliases: '-n'
  def create # (target_name = 'default', namespace_name = 'default')
    run(:create) # , target_name: target_name, namespace_name: namespace_name)
  end

  desc 'destroy [NAMESPACE]', 'Remove application from target infrastructure'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure to locate the namespace'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  option :yes, type: :boolean, desc: 'Do not prompt for confirmation'
  def destroy
    run(:destroy) if options.yes || yes?("\nWARNING!!! Destroy cannot be undone!\n\nAre you sure?")
  end


  # Cluster Runtime
  desc 'deploy', 'Deploy application to NAMESPACE on TARGET infrastructure'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure to locate the namespace'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  # option :local, type: :boolean, aliases: '-l', desc: 'Deploy from local; default is via CI/CD'
  def deploy
    run(:deploy)
  end

  desc 'redeploy', 'Create and Start'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure to locate the namespace'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  option :yes, type: :boolean, desc: 'Do not prompt for confirmation'
  def redeploy
    run(:redeploy) if options.yes || yes?("\nWARNING!!! Destroy cannot be undone!\n\nAre you sure?")
  end

  desc 'ps', 'List running services'
  option :format, type: :string, aliases: '-f', desc: ''
  option :status, type: :string, desc: 'created, restarting, running, removing, paused, exited, or dead'
  def ps(*args)
    run(:ps, args: args)
  end

  desc 'status', 'Show platform services status: created, restarting, running, removing, paused, exited, or dead'
  def status(status = :running)
    run(:status, status: status)
  end


  # Service Admin
  desc 'start', 'Start one or more services'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  # option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
  # option :build, type: :boolean, aliases: '-b', desc: 'Build image before run'
  # option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
  # option :console, type: :boolean, aliases: '-c', desc: "Connect to service's rails console after starting"
  # option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
  # option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  # option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after starting'
  def start(*service_names)
    run(:start, service_names: service_names)
  end

  desc 'restart SERVICE', 'Stop and start one or more services'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  # option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after executing command'
  # option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing command'
  # option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
  # option :console, type: :boolean, aliases: '-c', desc: 'Connect to service console after executing command'
  # option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
  # option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  # option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after executing command'
  def restart(*service_names)
    run(:restart, service_names: service_names)
  end

  desc 'stop SERVICE', 'Stop one or more services'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  def stop(*service_names)
    run(:stop, service_names: service_names)
  end

  desc 'terminate SERVICE', 'Terminate one or more services'
  option :target_names, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  def terminate(*service_names)
    run(:terminate, service_names: service_names)
  end


  # Service Runtime
  desc 'attach SERVICE', 'Attach to a running service; ctrl-f to detach; ctrl-c to stop/kill the service'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure to locate the namespace'
  option :namespace_name, type: :string, aliases: '-n', desc: 'Namespace in the target infrastructure where the service is running'
  def attach(service_name)
    # binding.pry
    run(:attach, service_name: service_name)
  end

  # NOTE: This is a test to run a command with multiple arguments; different from exec
  desc 'command COMMAND', 'Run specified command on a service'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure to locate the namespace'
  option :namespace_name, type: :string, aliases: '-n', desc: 'Namespace in the target infrastructure where the service is running'
  map %w[cmd] => :command
  def command(service_name, *args)
    run(:command, service_name: service_name, command: args)
  end

  desc 'console [SERVICE]', 'Start a cnfs or service console'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  def console(service_name = nil)
    service_name ? run(:console, service_name: service_name) : run(:console)
  end

  desc 'copy SRC DEST', 'Copy a file to or from a running service'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  map %w[cp] => :copy
  def copy(src, dest)
    run(:copy, src: src, dest: dest)
  end

  desc 'credentials', 'Display IAM credentials'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  option :format, type: :string, aliases: '-f', desc: 'Options: sdk, cli, postman'
  def credentials
    run(:credentials)
  end

  desc 'exec SERVICE COMMAND', 'Execute a command on a running service'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  def exec(service_name, *command_args)
    run(:exec, service_name: service_name, command_args: command_args)
  end

  desc 'logs', 'Tail logs of a running service'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  option :tail, type: :boolean, aliases: '-f'
  def logs(service_name)
    run(:logs, service_name: service_name)
  end

  desc 'sh SERVICE', 'Execute an interactive shell on a service'
  option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  option :namespace_name, type: :string, aliases: '-n'
  option :application_name, type: :string, aliases: '-a'
  # option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing shell'
  # NOTE: shell is a reserved word in Thor so it can't be used
  def sh(service_name)
    run(:shell, service_name: service_name)
  end


  # Utility
  desc 'version', 'Show cnfs version'
  def version
    puts "v#{Cnfs::VERSION}"
  end

  # desc 'up SERVICE', 'bring up service(s)'
  # option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
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
