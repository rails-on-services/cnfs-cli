# frozen_string_literal: true

module Primary
  class ListController < ApplicationController
    def execute
      require 'tty-tree'
      data = deployments(cli_args).each_with_object({}) do |deployment, hash|
        item = deploy_hash(deployment)
        hash[deployment.name] = [item] unless item.empty?
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
