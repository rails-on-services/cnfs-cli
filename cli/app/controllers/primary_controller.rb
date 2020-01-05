# frozen_string_literal: true

class PrimaryController < CommandsController
  register TargetsController, 'target', 'target [SUBCOMMAND]', 'Manage target infrastructure'

  class_option :verbose, type: :boolean, aliases: '-v'
  class_option :quiet, type: :boolean, aliases: '-q'
  class_option :debug, type: :numeric, aliases: '-d'
  class_option :noop, type: :boolean, aliases: '--noop'
  class_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'

  class_option :target_name, type: :string, aliases: '-t', desc: 'The target infrastructure'
  class_option :namespace_name, type: :string, aliases: '-n'
  class_option :profile_name, type: :string, aliases: '-p'
  class_option :application_name, type: :string, aliases: '-a'
  class_option :service_names, type: :array, aliases: '-s'
  # class_option :tag_name, type: :string, aliases: '--tag'


  # Global commands
  desc 'version', 'cnfs version'
  def version; puts "v#{Cnfs::VERSION}" end

  desc 'console [SERVICE]', 'Start a cnfs or service console'
  def console(service_name = nil); run(:console, service_names: service_name) end

  desc 'new', 'Create a new CNFS project'
  def new(name)
    NewController.new(name, options).execute
  end

  desc 'attach SERVICE', 'Attach to a running service; ctrl-f to detach; ctrl-c to stop/kill the service'
  def attach(servcie_name); run(:attach, service_name: service_name) end

  desc 'build APPLICATION [SERVICES]', 'Build all application images or just for specifc services'
  option :shell, type: :boolean, aliases: '-s', desc: 'Connect to service shell after building'
  def build; run(:build) end

  desc 'cmd', 'Run arbitrary command in context'
  def cmd(*args); run(:cmd, args) end

  # desc 'console', 'C
  # def copy(*args); run(:copy, args) end

  desc 'copy', 'Copy a file to or from a running service'
  def copy(*args); run(:copy, args) end

  desc 'create SERVICE', 'Create a namespace'
  def create(*args); run(:create, args) end

  desc 'credentials', 'show iam credentials'
  option :format, type: :string, aliases: '-f'
  def credentials; run(:credentials, args) end

  desc 'deploy', 'Deploy backend application to infrastructure targets'
  method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
  option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before run'
  option :console, type: :boolean, aliases: '-c', desc: "Connect to service's rails console after starting"
  option :daemon, type: :boolean, aliases: '-d', desc: 'Run in the background'
  option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after starting'
  def deploy(*args); run(:deploy, args) end

  desc 'destroy', 'Remove backend application from target infrastructure'
  method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
  def destroy(*args)
    if options[:help]
      invoke :help, ['destroy']
    else
      # TODO: are you sure?
      run(:destroy, args)
    end
  end

  desc 'exec COMMAND', 'Execute a command on a running service'
  def exec(command_name); run(:exec,  params(:exec, binding), { service_names: 1 }) end

  desc 'generate', 'Generate manifests for application deployment'
  def generate; run(:generate) end

  desc 'init', 'Initialize a project environment'
  def init; run(:init) end

  desc 'list', 'List backend application configuration objects'
  option :show_enabled, type: :boolean, aliases: '--enabled', desc: 'Only show services enabled in current config file'
  map %w(ls) => :list
  def list; run(:list) end

  desc 'logs', 'Tail logs of a running service'
  option :tail, type: :boolean, aliases: '-f'
  def logs(*args); run(:logs, args) end

  desc 'ps', 'List running services'
  option :format, type: :string, aliases: '-f'
  option :status, type: :string, aliases: '-s'
  def ps(*args); run(:ps, args) end

  desc 'publish', 'Publish API documentation to Postman'
  option :force, type: :boolean, aliases: '-f', desc: 'Force generation of new documentation'
  def publish(type, *services)
    raise Error, set_color("types are 'postman' and 'erd'", :red) unless %w(postman erd).include?(type)
  end

  desc 'pull IMAGE', 'push one or all images'
  def pull(*args); run(:pull, args) end

  desc 'push IMAGE', 'push one or all images'
  def push(*args); run(:push, args) end

=begin
  desc 'xdeploy API', 'deploy to UAT at an endpoint'
  def xdeploy(tag_name)
  end

  desc 'up SERVICE', 'bring up service(s)'
  option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before run'
  option :console, type: :boolean, aliases: '-c', desc: "Connect to service's rails console after starting"
  option :daemon, type: :boolean, aliases: '-d', desc: 'Run in the background'
  option :force, type: :boolean, default: false, aliases: '-f', desc: 'Force cluster creation'
  option :profile, type: :string, aliases: '-p', desc: 'Service profile to bring up'
  option :replicas, type: :numeric, aliases: '-r', desc: 'Number of containers (instance) or pods (kubernetes) to run'
  option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after starting'
  option :skip, type: :boolean, aliases: '--skip', desc: 'Skip starting services (just initialize cluster)'
  option :skip_infra, type: :boolean, aliases: '--skip-infra', desc: 'Skip deploy infra services'
  def up(*services)
    command = context(options)
    command.up(services)
    command.exit
  end

  desc 'server PROFILE', 'Start all services (short-cut alias: "s")'
  option :daemon, type: :boolean, aliases: '-d'
  # option :environment, type: :string, aliases: '-e', default: 'development'
  def server(*services)
    # TODO: Test this
    # Ros.load_env(options.environment) if options.environment != Ros.default_env
    command = context(options)
    command.up(services)
    command.exit
  end
=end

  # TODO: refactor to a rails specifc set of commands in a dedicated file
  # TODO: see about using little plugger for this one
  desc 'rails SERVICE COMMAND', 'execute a rails command on a service'
  def rails(service, cmd)
    exec(service, "rails #{cmd}")
  end

  desc 'redeploy', 'Create and Start'
  def redeploy
  end

  desc 'restart SERVICE', 'Start and stop one or more services'
  option :attach, type: :boolean, aliases: '-a', desc: 'Attach to service after executing command'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing command'
  option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
  option :console, type: :boolean, aliases: '-c', desc: 'Connect to service console after executing command'
  option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
  option :shell, type: :boolean, aliases: '-s', desc: 'Connect to service shell after executing command'
  def restart(*args)
    run(:restart, args)
  end

  desc 'sh SERVICE', 'execute an interactive shell on a service'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing shell'
  # NOTE: shell is a reserved word in Thor so it can't be used
  def sh(*args)
    validate_one_service(args)
    run(:shell, args)
  end

  desc 'show', 'show service config'
  option :modifier, type: :string, aliases: '-m'
  def show(*args)
    validate_one_service(args)
    run(:show, args)
  end

  desc 'start', 'Start a layer or service'
  option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
  option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
  def start(*args); run(:start, args) end

  desc 'status', 'Show platform services status'
  def status(*args) run(:status, args) end

  desc 'stop SERVICE', 'Stop a service'
  def stop(*args); run(:stop, args) end

  desc 'terminate SERVICE', 'Terminate a service'
  def terminate(*args); run(:terminate, args) end

  desc 'test IMAGE', 'Run tests on image(s)'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before testing'
  option :fail_all, type: :boolean, aliases: '-a', desc: 'Skip any remaining services after a test fails'
  option :fail_fast, type: :boolean, aliases: '-f', desc: 'Skip any remaining tests for a service after a test fails'
  option :push, type: :boolean, desc: 'Push image after successful testing'
  def test(*args); run(:test, args) end
end
