# frozen_string_literal: true

module Services
  class CommandController < Thor
    include Concerns::CommandController

    # Define common options for this controller
    add_cnfs_option :attach,   desc: "Connect to service's running process ",
                               aliases: '-a', type: :string
    add_cnfs_option :build,    desc: 'Build image before executing command',
                               aliases: '-b', type: :boolean
    add_cnfs_option :console,  desc: "Connect to service's console",
                               aliases: '-c', type: :string
    add_cnfs_option :profiles, desc: 'Service profiles',
                               aliases: '-p', type: :array
    add_cnfs_option :profile,  desc: 'Service profile',
                               aliases: '-p', type: :string
    add_cnfs_option :sh,       desc: "Connect to service's OS shell",
                               aliases: '--sh', type: :string

    cnfs_class_options :dry_run, :generate, :quiet
    cnfs_class_options Cnfs.config.segments.keys

    # Service Runtime
    desc 'attach SERVICE', 'Attach to the process of a running service (short-cut: a)'
    long_desc <<-DESC.gsub("\n", "\x5")

  The 'cnfs attach' command attaches to the process of a running service

  ctrl-f to detach; ctrl-c to stop/kill the service
    DESC
    cnfs_options :tags, :profile, :build
    def attach(service) = execute(service: service)

    # NOTE: This is a test to run a command with multiple arguments; different from exec
    # desc 'command COMMAND', 'Run specified command on a service'
    # map %w[cmd] => :command
    # def command(service, *args)
    #   run(:command, service: service, command: args)
    # end

    desc 'console SERVICE', 'Start a console on a running service (short-cut: c)'
    cnfs_options :profile
    # map %w[c] => :console
    def console(service) = execute(service: service)

    desc 'copy SRC DEST', 'Copy a file to/from a running service (short-cut: cp)'
    long_desc <<-DESC.gsub("\n", "\x5")

  The 'cnfs copy' command copies a file from/to a running service to/from the local file system

  To copy from a service: cnfs service copy service_name:path/to/file local/path/to/file

  To copy to a service: cnfs service copy local/path/to/file service_name:path/to/file
    DESC
    cnfs_options :profile
    map %w[cp] => :copy
    def copy(src, dest = nil)
      # TODO: Refactor; User can provide an absolute or relative path
      dest ||= project.write_path(:services).join(src.split(':').last.to_s.delete_prefix('/'))
      execute(src: src, dest: dest)
    end

    desc 'exec SERVICE COMMAND', 'Execute a command on a running service'
    cnfs_options :profile
    def exec(service, *command) = super(service: service, command: command)

    desc 'logs SERVICE', 'Display the logs of a running service'
    cnfs_options :profile
    option :tail, desc: 'Continuous logging',
                  aliases: '-f', type: :boolean
    def logs(service) = execute(service: service)

    desc 'ps', 'List running services'
    option :format, desc: 'Format output',
                    type: :string, aliases: '-f'
    option :status, desc: 'created, restarting, running, removing, paused, exited or dead',
                    type: :string, default: 'running'
    # TODO: This is not working
    def ps(*args) = execute(args: args)

    desc 'restart [SERVICES]', 'Stop and start one or more running services'
    cnfs_options :attach, :build, :console, :profiles, :sh, :tags
    # TODO: When taking array of services but attach only uses the last one
    # Add default: '' so if -a is passed and value is blank then it's the last one
    # NOTE: Seed the database before executing command
    option :clean, desc: 'Perform a clean restart equivalent to terminate and start',
                   aliases: '--clean', type: :boolean
    # option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
    # option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
    # TODO: Implement clean
    def restart(*services) = execute(services: services)

    desc 'sh SERVICE', 'Execute an interactive shell on a running service'
    # NOTE: shell is a reserved word in Thor so it can't be used as a method name
    def sh(service) = execute(method: :shell, service: service)

    desc 'show SERVICE', 'Display the service manifest'
    option :modifier, desc: "A suffix applied to service name, e.g. '.env'",
                      aliases: '-m', type: :string
    def show(*services) = execute(services: services)

    desc 'start [SERVICES]', 'Start one or more services (short-cut: s)'
    cnfs_options :attach, :build, :console, :profiles, :sh
    # option :clean, type: :boolean, aliases: '--clean', desc: 'Seed the database before executing command'
    option :foreground, type: :boolean, aliases: '-f', desc: 'Run in foreground (default is daemon)'
    # option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
    # TODO: Take a profile array also. The config should define a default profile
    map %w[s] => :start
    def start(*services) = execute(services: services)

    desc 'stop [SERVICES]', 'Stop one or more running services'
    cnfs_options :profiles
    def stop(*services) = execute(services: services)

    desc 'terminate [SERVICES]', 'Terminate one or more running services'
    cnfs_options :tags, :profiles
    def terminate(*services) = execute(services: services)

    # TODO: refactor publish; move to cnfs-backend gem; It should be loaded into this controller
    desc 'publish SERVICE', 'Publish API documentation to Postman'
    option :force, desc: 'Force generation of new documentation',
                   aliases: '-f', type: :boolean
    # Maybe in the service configuration is an attribute commands which is an array of hashes:
    # { command: 'publish erd', exec: 'rails g erd' }
    # Maybe publish is not a full command but there is a command method which then parses the array of hashes
    # In that case test could be put into this array as well
    def publish(type, *_services)
      raise Cnfs::Error, set_color("types are 'postman' and 'erd'", :red) unless %w[postman erd].include?(type)
    end

    # desc 'up SERVICE', 'bring up service(s)'
    # option :replicas, type: :numeric, aliases: '-r', desc: 'Number of containers (instance) or pods (k8s) to run'
    # option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
  end
end
