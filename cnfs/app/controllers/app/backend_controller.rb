# frozen_string_literal: true

module App
  class BackendController < ApplicationController
    # namespace 'application backend' #:backend
    class_option :verbose, type: :boolean, default: false, aliases: '-v'
    class_option :debug, type: :numeric, default: 0, aliases: '--debug'
    class_option :noop, type: :boolean, aliases: '-n'
    class_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'

    class_option :deployment, type: :string, aliases: '-d'
    class_option :target, type: :string, aliases: '-t'
    class_option :layer, type: :string, aliases: '-l'

    # class_option :environment, type: :string, default: nil, aliases: '-e', desc: 'Environment'
    # class_option :profile, type: :string, default: nil, aliases: '-p', desc: 'profile'
    # class_option :feature_set, type: :string, default: nil, aliases: '--fs', desc: 'feature set'

    desc 'attach SERVICE', 'attach to a running service; ctrl-f to detach; ctrl-c to stop/kill the service'
    def attach(*args); run(:attach, args) end

    desc 'build IMAGE', 'build one or all images'
    option :shell, type: :boolean, aliases: '--sh', desc: 'Connect to service shell after building'
    def build(*args); run(:build, args) end

    desc 'cmd', 'Run arbitrary command in context'
    def cmd(*args); run(:cmd, args) end

    desc 'copy', 'Copy file to service'
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

    desc 'exec SERVICE COMMAND', 'execute a command on a service'
    def exec(*args); run(:exec, args) end

    desc 'generate', 'Generate manifests for deployment'
    # option :force, type: :boolean, default: false, aliases: '-f'
    def generate(*args); run(:generate, args) end

    # desc 'init', 'Initialize a project environment'
    # def init
    #   preflight_check(fix: true)
    #   preflight_check
    # end

    desc 'list', 'List backend application configuration objects'
    option :show_enabled, type: :boolean, aliases: '--enabled', desc: 'Only show services enabled in current config file'
    map %w(ls) => :list
    def list(what = 'deployments')
      run(:list, what)
    end

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
    # NOTE: shell is a reserved word in Thor so it can't be used
    option :build, type: :boolean, aliases: '-b', desc: 'Build image before executing shell'
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

    private

    def validate_one_service(args)
      raise Error, set_color('one service name is required', :red) unless args.size.eql?(1)
    end

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
