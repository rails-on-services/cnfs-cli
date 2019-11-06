# frozen_string_literal: true

module Cnfs
  module Commands
    module Application
      class Backend < Thor
        # namespace 'application backend' #:backend
        class_option 'verbose', type: :boolean, default: false, aliases: '-v'
        class_option 'debug', type: :numeric, default: 0, aliases: '-d'

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
            # binding.pry
            require_relative 'backend/deploy'
            Cnfs::Commands::Application::Backend::Deploy.new(services, options).execute
          end
        end

        desc 'destroy', 'Remove backend application from target infrastructure'
        method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
        def destroy # (name)
          if options[:help]
            invoke :help, ['destroy']
          else
            # TODO: are you sure?
            # binding.pry
            require_relative 'backend/destroy'
            Cnfs::Commands::Application::Backend::Destroy.new(options).execute
          end
        end

        # desc 'generate TYPE', 'Generate a new asset of type TYPE (short-cut alias: "g")'
        # map %w(g) => :generate
        # option :force, type: :boolean, default: false, aliases: '-f'
        # subcommand 'generate', Ros::Be::Application::GenerateCli

        # # TODO: refactor setting action to :destroy
        # desc 'destroy TYPE', 'Destroy an asset (environment or service)'
        # option :behavior, type: :string, default: 'revoke'
        # map %w(d) => :destroy
        # subcommand 'destroy', Ros::Be::Application::GenerateCli

        # desc 'init', 'Initialize a project environment'
        # def init
        #   preflight_check(fix: true)
        #   preflight_check
        # end

        desc 'status', 'Show platform services status'
        def status
          require_relative 'backend/ps'
          require_relative 'backend/status'
          # TODO: Use a method that returns a Cnfs::Core::Platform class rather than direct access to Cnfs.platform
          # so that any instance of that class can be returned
          Cnfs.platform.infra.deployments.each do |orchestrator|
            Cnfs::Commands::Application::Backend::Status.new(options.merge(orchestrator: orchestrator)).execute
          end
        end

        desc 'build IMAGE', 'build one or all images'
        option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after building'
        def build(*services)
          require_relative 'backend/ps'
          require_relative 'backend/build'
          Cnfs.platform.infra.deployments.each do |orchestrator|
            Cnfs::Commands::Application::Backend::Build.new(services, options).execute(orchestrator: orchestrator)
          end
        end

        desc 'test IMAGE', 'test one or all images'
        option :build, type: :boolean, aliases: '-b', desc: 'Build image before testing'
        option :fail_all, type: :boolean, aliases: '-a', desc: 'Skip any remaining services after a test fails'
        option :fail_fast, type: :boolean, aliases: '-f', desc: 'Skip any remaining tests for a service after a test fails'
        option :push, type: :boolean, aliases: '-p', desc: 'Push image after successful testing'
        def test(*services)
          require_relative 'backend/test'
          Cnfs.platform.infra.deployments.each do |orchestrator|
            Cnfs::Commands::Application::Backend::Test.new(services, options).execute(orchestrator: orchestrator)
          end
        end


        desc 'push IMAGE', 'push one or all images'
        def push(*services)
          command = context(options)
          command.push(services)
          command.exit
        end

        desc 'pull IMAGE', 'push one or all images'
        def pull(*services)
          command = context(options)
          command.pull(services)
          command.exit
        end

        desc 'attach SERVICE', 'attach to a running service; ctrl-f to detach; ctrl-c to stop/kill the service (short-cut alias: "at")'
        map %w(at) => :attach
        def attach(service)
          command = context(options)
          command.attach(service)
          command.exit
        end

        desc 'copy', 'Copy file to service'
        option :environment, type: :string, aliases: '-e', desc: 'Environment'
        option :profile, type: :string, aliases: '-p', desc: 'profile'
        def copy(service, src, dest = nil)
          command = context(options)
          command.copy(service, src, dest)
          command.exit
        end

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

        desc 'cmd', 'Run arbitrary command in context'
        def cmd(*services)
          command = context(options)
          command.cmd(services)
          command.exit
        end

        desc 'ps', 'List running services'
        def ps(*)
          if options[:help]
            invoke :help, ['ps']
          else
            require_relative 'backend/ps'
            Cnfs.platform.infra.deployments.each do |orchestrator|
              Cnfs::Commands::Application::Backend::Ps.new(options.merge(orchestrator: orchestrator)).execute
            end
          end
        end

        desc 'show', 'show service config'
        def show(service)
          command = context(options)
          command.show(service)
          command.exit
        end

        desc 'credentials', 'show iam credentials'
        def credentials
          command = context(options)
          command.credentials
          command.exit
        end

        desc 'console', 'Start the Ros console (short-cut alias: "con")'
        def console(service)
          binding.pry
          command = context(options)
          command.console(service)
          command.exit
        end

        desc 'exec SERVICE COMMAND', 'execute an interactive command on a service (short-cut alias: "e")'
        map %w(e) => :exec
        def exec(service, cmd)
          command = context(options)
          command.exec(service, cmd)
          command.exit
        end

        # TODO: refactor to a rails specifc set of commands in a dedicated file
        desc 'rails SERVICE COMMAND', 'execute a rails command on a service (short-cut alias: "r")'
        map %w(r) => :rails
        def rails(service, cmd)
          exec(service, "rails #{cmd}")
        end

        desc 'sh SERVICE', 'execute an interactive shell on a service'
        # NOTE: shell is a reserved word in Thor so it can't be used
        option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing shell'
        def sh(service)
          exec(service, 'bash')
        end

        desc 'logs', 'Tail logs of a running service'
        option :tail, type: :boolean, aliases: '-f'
        def logs(service)
          command = context(options)
          command.logs(service)
          command.exit
        end

        desc 'restart SERVICE', 'Start and stop one or more services'
        option :attach, type: :boolean, aliases: '--at', desc: 'Attach to service after starting'
        option :console, type: :boolean, aliases: '-c', desc: 'Connect to service console after starting'
        option :daemon, type: :boolean, aliases: '-d', desc: 'Run in the background (default, does noting)'
        option :seed, type: :boolean, aliases: '--seed', desc: 'Seed the database before starting the service'
        option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after starting'
        def restart(*services)
          command = context(options)
          command.restart(services)
          command.exit
        end

        desc 'stop SERVICE', 'Stop a service'
        def stop(*services)
          command = context(options)
          command.stop(services)
          command.exit
        end

        desc 'down', 'bring down platform'
        def down(*services)
          command = context(options)
          command.down(services)
          command.exit
        end

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

        desc 'publish', 'Publish API documentation to Postman'
        option :force, type: :boolean, aliases: '-f', desc: 'Force generation of new documentation'
        def publish(type, *services)
          raise Error, set_color("types are 'postman' and 'erd'", :red) unless %w(postman erd).include?(type)
          command = context(options)
          command.publish(type, services)
          command.exit
        end

        private
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
