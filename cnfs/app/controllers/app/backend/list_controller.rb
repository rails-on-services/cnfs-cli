# frozen_string_literal: true

module App::Backend
  class ListController < Cnfs::Command
    def execute
      unless respond_to?(args)
        output.puts 'try another'
        return
      end
      send(args)
      # STDOUT.puts what.classify.safe_constantize.all.pluck(:name).sort
      # binding.pry
      # what = "infra/#{what}" if %w[targets runtimes].include? what
      # what = "app/#{what}" if %w[layers services].include? what
    end

    def deployments
      require 'tty-tree'
      deployments = options.deployment ? Deployment.where(name: options.deployment) : Deployment.all
      data = deployments.each_with_object({}) do |d, hash|
        app = d.application
        hash[d.name] = [{
          targets: [ d.targets.pluck(:name) ],
          application: [ { services: app.services.pluck(:name), resources: app.resources.pluck(:name) }]
        }]
      end
      output.puts(TTY::Tree.new(data).render)
    end

    def application
      app.layers.each_with_object([]) do |layer, ary|
        ary.append(
          { }
        )
      end
    end
  end
end
