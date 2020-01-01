# frozen_string_literal: true

module Primary
  class InitController < ApplicationController
    # This maybe isn't necessary
    # The application should check if the path exists
    # If it does not and there is a git repo defined then go get it
    def execute
      binding.pry
    end

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
  end
end
