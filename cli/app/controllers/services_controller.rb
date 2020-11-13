# frozen_string_literal: true

class ServicesController < CommandsController
  OPTS = %i[env ns noop quiet verbose]
  include Cnfs::Options

  register Services::AddController, 'add', 'add TYPE NAME', 'Add a service to the project configuration'
  register Services::NewController, 'new', 'new SUBCOMMAND [options]', 'Create a new service in the default (or specified) repository'

  # TODO: Implement list
  desc 'list', 'Lists services configured in the project'
  # option :environment, desc: 'Target environment',
  #   aliases: '-e', type: :string
  # option :namespace, desc: 'Target namespace',
  #   aliases: '-n', type: :string
  map %w[ls] => :list
  def list
    binding.pry
    # run(:list)
  end

  # TODO: Implement remove
  desc 'remove NAME', 'Remove a service from the project configuration (short-cut: rm)'
  option :environment, desc: 'Target environment',
    aliases: '-e', type: :string
  option :namespace, desc: 'Target namespace',
    aliases: '-n', type: :string
  option :repository, desc: 'Remove the service from a repository',
    aliases: '-r', type: :string
  map %w[rm] => :remove
  def remove(name)
    return unless (options.force || yes?("\n#{'WARNING!!!  ' * 5}\nThis will destroy the service.\nAre you sure?"))

    # cs = controller_class(:service).new
    # cs.action = :revoke
    # cs.send(name)
    # run(:service, name: name)
  end

  desc 'show SERVICE', 'Display the service manifest'
  option :modifier,  desc: "A suffix applied to service name, e.g. '.env'",
    aliases: '-m', type: :string
  def show(*services)
    run(:show, services: services)
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

  # Service Admin
  desc 'start [SERVICES]', 'Start one or more services (short-cut: s)'
  option :attach, desc: 'Attach to service after starting',
    aliases: '-a', type: :boolean
  # option :build, type: :boolean, aliases: '-b', desc: 'Build image before run'
  # option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
  option :console, desc: "Connect to service's rails console after starting",
    aliases: '-c', type: :boolean
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

  desc 'restart [SERVICES]', 'Stop and start one or more running services'
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

  desc 'stop [SERVICES]', 'Stop one or more running services'
  option :profiles, desc: 'List of profiles to stop',
    aliases: '-p', type: :array
  def stop(*services)
    run(:stop, services: services)
  end

  desc 'terminate [SERVICES]', 'Terminate one or more running services'
  option :profiles, desc: 'List of profiles to terminate',
    aliases: '-p', type: :array
  def terminate(*services)
    run(:terminate, services: services)
  end

  # Service Runtime
  desc 'attach SERVICE', 'Attach to the process of a running service (short-cut: a)'
  long_desc <<-DESC.gsub("\n", "\x5")

  The 'cnfs attach' command attaches to the process of a running service

  ctrl-f to detach; ctrl-c to stop/kill the service
  DESC
  option :build, desc: 'Build image before executing command',
    aliases: '-b', type: :boolean
  option :profile, desc: 'Service profiles',
    aliases: '-p', type: :string
  map %w[a] => :attach
  def attach(service)
    run(:attach, service: service)
  end

  # NOTE: This is a test to run a command with multiple arguments; different from exec
  # desc 'command COMMAND', 'Run specified command on a service'
  # map %w[cmd] => :command
  # def command(service, *args)
  #   run(:command, service: service, command: args)
  # end

  desc 'console SERVICE', 'Start a console on a running service (short-cut: c)'
  map %w[c] => :console
  def console(service)
    run(:console, service: service)
  end

  desc 'copy SRC DEST', 'Copy a file to/from a running service (short-cut: cp)'
  long_desc <<-DESC.gsub("\n", "\x5")

  The 'cnfs copy' command copies a file from/to a running service to/from the local file system

  To copy from a service: cnfs service copy service_name:path/to/file local/path/to/file

  To copy to a service: cnfs service copy local/path/to/file service_name:path/to/file
  DESC
  map %w[cp] => :copy
  def copy(src, dest)
    run(:copy, src: src, dest: dest)
  end

  desc 'exec SERVICE COMMAND', 'Execute a command on a running service'
  def exec(service, *command_args)
    run(:exec, service: service, command_args: command_args)
  end

  desc 'logs SERVICE', 'Display the logs of a running service'
  option :tail, desc: 'Continuous logging',
    aliases: '-f', type: :boolean
  def logs(service)
    run(:logs, service: service)
  end

  desc 'sh SERVICE', 'Execute an interactive shell on a running service'
  option :build, desc: 'Build image before executing shell',
    aliases: '-b', type: :boolean
  # NOTE: shell is a reserved word in Thor so it can't be used
  def sh(service)
    arguments = { service: service }
    arguments.merge!(services: [service]) if options.build
    run(:shell, arguments)
  end

  # Commands ot refactor
  desc 'publish SERVICE', 'Publish API documentation to Postman'
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
