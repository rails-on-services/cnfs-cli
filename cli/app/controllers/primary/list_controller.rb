# frozen_string_literal: true

module Primary
  class ListController < ApplicationController
    def execute
      require 'tty-tree'
      send("execute_#{args.what}")
    end

    def execute_ns
      each_target do
        # binding.pry
        runtime.run('get ns').run!
      end
    end
    # Service.joins(:tags).where(tags: {name: Tag.last.name})

    def execute_profiles
      data = Profile.all.each_with_object({}) do |profile, hash|
        item = []
        item.append("target: #{profile.target.name}") if profile.target
        item.append("namespace: #{profile.namespace}") if profile.namespace
        item.append("application: #{profile.application.name}") if profile.application
        %w[resources services].each do |attribute|
          item.append("#{attribute}: #{YAML.load(profile.send(attribute)).join(', ')}") if profile.send(attribute)
        end
        hash[profile.name] = item unless item.empty?
      end
      output.puts(TTY::Tree.new(data).render)
    end

    def execute_deployments
      data = deployments(cli_args).each_with_object({}) do |deployment, hash|
        item = deploy_hash(deployment)
        hash[deployment.name] = item unless item.empty?
      end
      output.puts(TTY::Tree.new(data).render)
    end

    def deploy_hash(deployment)
      result = {}
      result[:target] = ta_hash(deployment.target) unless ta_hash(deployment.target).empty?
      result[:application] = ta_hash(deployment.application) unless ta_hash(deployment.application).empty?
      result
    end

    def ta_hash(ta)
      result = {}
      services = ta.services
      services = services.where(name: cli_args.service_names) if cli_args.service_names
      result[:services] = services.pluck(:name) if services.size.positive?
      resources = ta.resources
      resources = [] if cli_args.service_names
      result[:resources] = resources.pluck(:name) if resources.size.positive?
      result
    end
  end
end
