# frozen_string_literal: true

module Cnfs
  module Commands
    module Application
      # The backend router that routes command requests to the appropriate controller (command class)
      class Backend < Thor
        attr_accessor :platform
        # namespace 'application backend' #:backend
        class_option :verbose, type: :boolean, default: false, aliases: '-v'
        class_option :debug, type: :numeric, default: 0, aliases: '-d'
        class_option :environment, type: :string, default: nil, aliases: '-e', desc: 'Environment'
        class_option :profile, type: :string, default: nil, aliases: '-p', desc: 'profile'
        class_option :feature_set, type: :string, default: nil, aliases: '--fs', desc: 'feature set'

        desc 'attach SERVICE', 'attach to a running service; ctrl-f to detach; ctrl-c to stop/kill the service'
        def attach(name, target = nil)
          # TODO: if target is nil then target is default (first) deployment target
          # TODO: one interface for run, rather than run and run_all. some way to create an array of
          # one if the target is default
          run(target, :attach, name: name)
          # execute_all(:attach, name: name)
        end

        no_commands do
          def run_all(command, params = {})
            platform.infra.deployments.keys.each do |target|
              run(target, command, params)
            end
            nil
          end

          def run(target = [], command = '', params = {})
            command_string = command.to_s.camelize
            command = "#{self.class.name}::#{command_string}".safe_constantize
            # TODO: merge config hash with the target's config (or as a separate sub-key in the config)
            config = { target: target, command: command_string, platform: platform, orchestrator: :compose }
            command.new(params, options, config).execute
          end
        end

        desc 'build IMAGE', 'build one or all images'
        option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after building'
        def build(*services)
          run_all(:build, services: services)
        end

        desc 'cmd', 'Run arbitrary command in context'
        def cmd(*services) #, target = nil)
        end

        desc 'copy', 'Copy file to service'
        def copy(service, src, dest = nil)
        end

        desc 'credentials', 'show iam credentials'
        def credentials
        end

        desc 'deploy', 'Deploy backend application to target infrastructure'
        method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
        option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
        option :build, type: :boolean, aliases: '-b', desc: 'Build image before run'
        option :console, type: :boolean, aliases: '-c', desc: "Connect to service's rails console after starting"
        option :daemon, type: :boolean, aliases: '-d', desc: 'Run in the background'
        option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after starting'
        def deploy(*services)
          if options[:help]
            invoke :help, ['deploy']
          else
            Deploy.new(services, options).execute
          end
        end

        desc 'destroy', 'Remove backend application from target infrastructure'
        method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
        def destroy # (name)
          if options[:help]
            invoke :help, ['destroy']
          else
            # TODO: are you sure?
            Destroy.new(options).execute
          end
        end

        desc 'exec SERVICE COMMAND', 'execute an interactive command on a service (short-cut alias: "e")'
        def exec(service, cmd)
        end

        desc 'generate', 'Generate manifests for deployment'
        # option :force, type: :boolean, default: false, aliases: '-f'
        def generate
          run(nil, :generate)
        end

        # desc 'init', 'Initialize a project environment'
        # def init
        #   preflight_check(fix: true)
        #   preflight_check
        # end

        desc 'list', 'List backend application configuration objects'
        option :show_enabled, type: :boolean, aliases: '--enabled', desc: 'Only show services enabled in current config file'
        map %w(ls) => :list
        def list(what = nil)
          STDOUT.puts 'Options: infra, services, platform' if what.nil?
          STDOUT.puts "#{Settings.components.be.components.application.components[what].components.keys.join("\n")}" unless what.nil? or options.show_enabled
          if options.show_enabled
            case what
            when 'platform'
              STDOUT.puts enabled_services
            when 'services'
              STDOUT.puts enabled_application_services
            end
          end
        end

        desc 'logs', 'Tail logs of a running service'
        option :tail, type: :boolean, aliases: '-f'
        def logs(service)
          run(nil, :logs, service: service)
        end

        desc 'ps', 'List running services'
        option :status, type: :string, default: 'running', aliases: '-s'
        def ps(*)
          if options[:help]
            invoke :help, ['ps']
          else
            run_all(:ps)
          end
        end

        desc 'publish', 'Publish API documentation to Postman'
        option :force, type: :boolean, aliases: '-f', desc: 'Force generation of new documentation'
        def publish(type, *services)
          raise Error, set_color("types are 'postman' and 'erd'", :red) unless %w(postman erd).include?(type)
        end

        desc 'pull IMAGE', 'push one or all images'
        def pull(*services)
        end

        desc 'push IMAGE', 'push one or all images'
        def push(*services)
        end

=begin
        desc 'xdeploy API', 'deploy to UAT at an endpoint'
        def xdeploy(tag_name)
          # prefix = Settings.components.be.components.application.config.deploy_tag
          prefix = 'enable-api.'
          api_tag_name = "#{prefix}#{tag_name}"
          existing_local_tags = %x(git tag).split
          existing_remote_tags = %x(git ls-remote --tags).split("\n").map { |tag_string| tag_string.split("\t").last.gsub('refs/tags/', '') }
          versions = []
          (existing_local_tags + existing_remote_tags).select { |tag| tag.match?(/#{api_tag_name}\.[v]\d+$/i) }.each do |tag|
            # push numeric version suffix into versions array
            versions.push(tag[/\d+$/].to_i)
          end
          versions.sort!.reverse!
          # bump version
          version = "v#{versions[0].to_i + 1}"
          # retag local
          %x(git tag -a -m #{api_tag_name}.#{version} #{api_tag_name}.#{version})
          # push tag
          %x(git push origin #{api_tag_name}.#{version})
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
        desc 'rails SERVICE COMMAND', 'execute a rails command on a service'
        def rails(service, cmd)
          exec(service, "rails #{cmd}")
        end

        desc 'redeploy', 'Create and Start'
        def redeploy
        end

        desc 'restart SERVICE', 'Start and stop one or more services'
        option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
        option :console, type: :boolean, aliases: '-c', desc: 'Connect to service console after starting'
        option :daemon, type: :boolean, aliases: '-d', desc: 'Run in the background (default, does noting)'
        option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
        option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after starting'
        def restart(*services)
        end

        desc 'sh SERVICE', 'execute an interactive shell on a service'
        # NOTE: shell is a reserved word in Thor so it can't be used
        option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing shell'
        def sh(service)
          Sh.new(options, { service: service }, platform, :noop, { orchestrator: :compose }).execute
        end

        desc 'show', 'show service config'
        def show(service)
          execute_on_each_deployment(Show, service: service) {}
        end

        desc 'start', 'Start a layer, profile or service'
        def start
        end

        desc 'status', 'Show platform services status'
        def status
          run(nil, :status)
        end

        desc 'stop SERVICE', 'Stop a service'
        def stop(*services)
        end

        desc 'test IMAGE', 'Run tests on image(s)'
        option :build, type: :boolean, aliases: '-b', desc: 'Build image before testing'
        option :fail_all, type: :boolean, aliases: '-a', desc: 'Skip any remaining services after a test fails'
        option :fail_fast, type: :boolean, aliases: '-f', desc: 'Skip any remaining tests for a service after a test fails'
        option :push, type: :boolean, desc: 'Push image after successful testing'
        def test(*services)
          run(nil, :test, services: services)
        end

        no_commands do
          # NOTE: To invoke a command from the CNFS console with a custom platform config:
          # platform = Cnfs::Core::Platform.new(env: :production)
          # router = Cnfs::Commands::Application::Backend.new([], platform: platform)
          # router.ps, router.status, etc
          def platform
            # TODO: move to run command once it is a single command
            ENV['CNFS_ENV'] = options.environment if options.environment
            ENV['CNFS_PROFILE'] = options.profile if options.profile
            ENV['CNFS_FS'] = options.feature_set if options.feature_set
            @platform ||= (options.platform || Cnfs.platform)
          end
        end

        private

        # def execute_on_each_deployment(klass, args = {})
        #   # Cnfs.platform.infra.deployments.each_pair do |deployment, config|
        #   #  klass.new(options.merge(orchestrator: config[:orchestrator]), args).execute
        #   platform.infra.deployments.each_pair do |name, deployment|
        #     klass.new(options, args, platform, name, deployment).execute
        #     yield
        #   end
        #   nil
        # end

=begin
        def preflight_check(fix: false)
          options = {}
          ros_repo = Dir.exists?(Ros.ros_root)
          environments = Dir["#{Ros.deployments_dir}/*.yml"].select{ |f| not File.basename(f).index('-') }.map{ |f| File.basename(f).chomp('.yml') }
          if fix
            %x(git clone git@github.com:rails-on-services/ros.git) unless ros_repo
            require 'ros/main/env/generator'
            environments.each do |env|
              Ros::Main::Env::Generator.new([env]).invoke_all if not File.exist?("#{Ros.environments_dir}/#{env}.yml")
            end
          else
            STDOUT.puts "ros repo: #{ros_repo ? 'ok' : 'missing'}"
            env_ok = environments.each do |env|
              break false if not File.exist?("#{Ros.environments_dir}/#{env}.yml")
            end
            STDOUT.puts "environment configuration: #{env_ok ? 'ok' : 'missing'}"
          end
        end

        def context(options = {})
          return @context if @context
          raise Error, set_color('ERROR: Not a Ros project', :red) if Ros.root.nil?

          require "ros/be/application/cli/#{infra_x.cluster_type}"
          @context = Ros::Be::Application.const_get(infra_x.cluster_type.capitalize).new(options)
          @context
        end
        def infra_x; Ros::Be::Infra::Model end
        def application; Ros::Be::Application::Model end
=end
      end
    end
  end
end
