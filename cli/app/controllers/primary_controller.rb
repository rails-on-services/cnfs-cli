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

  class_option :context_name, type: :string, aliases: '-c', desc: 'The context name to configure targets and applications'
  class_option :key_name, type: :string, aliases: '-k'
  class_option :target_name, type: :string, aliases: '-t', desc: 'Target infrastructure on which to run'
  class_option :namespace_name, type: :string, aliases: '-n'
  class_option :application_name, type: :string, aliases: '-a'
  class_option :service_names, type: :array, aliases: '-s'
  class_option :profile_names, type: :array, aliases: '-p'
  class_option :tag_names, type: :array, aliases: '--tags'

  desc 'attach SERVICE', 'Attach to a running service; ctrl-f to detach; ctrl-c to stop/kill the service'
  def attach(*service_name)
    run(:attach, service_names: service_name)
  end

  desc 'build APPLICATION [SERVICES]', 'Build all or specific application images'
  option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after building'
  def build
    run(:build)
  end

  desc 'command COMMAND', 'Run specified command on cluster'
  map %w[cmd] => :command
  def command(*args)
    run(:command, command: args)
  end

  desc 'console [SERVICE]', 'Start a cnfs or service console'
  def console(*service_name)
    run(:console, service_names: service_name)
  end

  desc 'copy SRC DEST', 'Copy a file to or from a running service'
  map %w[cp] => :copy
  def copy(src, dest)
    run(:copy, src: src, dest: dest)
  end

  desc 'create [NAMESPACE]', 'Create a new namespace'
  def create(namespace_name)
    run(:create, namespace_name: namespace_name)
  end

  desc 'credentials', 'Display IAM credentials'
  option :format, type: :string, aliases: '-f', desc: 'Options: sdk, cli, postman'
  def credentials
    run(:credentials)
  end

  desc 'deploy [NAMESPACE]', 'Deploy application to target infrastructure'
  option :local, type: :boolean, aliases: '-l', desc: 'Deploy from local; default is via CI/CD'
  def deploy(namespace_name = nil)
    run(:deploy, namespace_name: namespace_name)
  end

  desc 'destroy [NAMESPACE]', 'Remove application from target infrastructure'
  option :yes, type: :boolean, desc: 'Do not prompt for confirmation'
  def destroy(namespace_name = nil)
    return unless options.yes || yes?("\nWARNING!!! Destroy cannot be undone!\n\nAre you sure?")

    run(:destroy, namespace_name: namespace_name)
  end

  desc 'exec SERVICE COMMAND', 'Execute a command on a running service'
  def exec(service_name, command_name)
    run(:exec, service_names: [service_name], command_name: command_name)
  end

  desc 'generate', 'Generate manifests for application deployment'
  option :clean, type: :boolean, desc: 'Remove existing manifests before generating'
  def generate
    run(:generate)
  end

  desc 'init APPLICATION', 'Initialize an application'
  def init(application_name)
    run(:init, application_name: application_name)
  end

  desc 'list', 'List configuration objects: config, ns, contexts, deployments, applications'
  option :show_enabled, type: :boolean, aliases: '--enabled', desc: 'Only show services enabled in current config file'
  map %w[ls] => :list
  def list(what = :config)
    run(:list, what: what)
  end

  desc 'logs', 'Tail logs of a running service'
  option :tail, type: :boolean, aliases: '-f'
  def logs(*service_name)
    run(:logs, service_names: service_name)
  end

  desc 'new NAME', 'Create a new CNFS project'
  option :type, type: :string
  def new(name)
    NewController.new(name, options).execute
  end

  desc 'ps', 'List running services'
  option :format, type: :string, aliases: '-f', desc: ''
  option :status, type: :string, desc: 'created, restarting, running, removing, paused, exited, or dead'
  def ps(*args)
    run(:ps, args: args)
  end

  desc 'publish', 'Publish API documentation to Postman'
  option :force, type: :boolean, aliases: '-f', desc: 'Force generation of new documentation'
  # TODO: refactor
  def publish(type, *_services)
    raise Error, set_color("types are 'postman' and 'erd'", :red) unless %w[postman erd].include?(type)
  end

  desc 'pull IMAGE', 'Pull one or all images'
  # TODO: refactor
  def pull(*args)
    run(:pull, args)
  end

  desc 'push IMAGE', 'Push one or all images'
  # TODO: refactor
  def push(*args)
    run(:push, args)
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

  desc 'redeploy', 'Create and Start'
  def redeploy(namespace_name = nil)
    run(:redeploy, namespace_name: namespace_name)
  end

  desc 'restart SERVICE', 'Start and stop one or more services'
  option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after executing command'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing command'
  option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
  option :console, type: :boolean, aliases: '-c', desc: 'Connect to service console after executing command'
  option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
  option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after executing command'
  def restart(*service_names)
    run(:restart, service_names: service_names)
  end

  desc 'sh SERVICE', 'Execute an interactive shell on a service'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing shell'
  # NOTE: shell is a reserved word in Thor so it can't be used
  def sh(service_name)
    run(:shell, service_names: [service_name])
  end

  desc 'show', 'Show service config'
  option :modifier, type: :string, aliases: '-m'
  def show(*service_name)
    run(:show, service_names: service_name)
  end

  desc 'start', 'Start a layer or service'
  option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before run'
  option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
  option :console, type: :boolean, aliases: '-c', desc: "Connect to service's rails console after starting"
  option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
  option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after starting'
  def start(*service_names)
    run(:start, service_names: service_names)
  end

  desc 'status', 'Show platform services status: created, restarting, running, removing, paused, exited, or dead'
  def status(status = :running)
    run(:status, status: status)
  end

  desc 'stop SERVICE', 'Stop a service'
  def stop(*service_names)
    run(:stop, service_names: service_names)
  end

  desc 'terminate SERVICE', 'Terminate a service'
  def terminate(*service_names)
    run(:terminate, service_names: service_names)
  end

  desc 'test IMAGE', 'Run tests on image(s)'
  option :build, type: :boolean, aliases: '-b', desc: 'Build image before testing'
  option :fail_all, type: :boolean, aliases: '--fa', desc: 'Skip any remaining services after a test fails'
  option :fail_fast, type: :boolean, aliases: '--ff', desc: 'Skip any remaining tests for a service after a test fails'
  option :push, type: :boolean, desc: 'Push image after successful testing'
  def test(*args)
    run(:test, args)
  end

  desc 'version', 'Show cnfs version'
  def version
    puts "v#{Cnfs::VERSION}"
  end
end
