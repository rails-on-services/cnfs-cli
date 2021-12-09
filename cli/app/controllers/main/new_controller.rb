# frozen_string_literal: true

module Main
  class NewController
    include Concerns::ExecController

    attr_reader :name

    def execute
      return unless validate_execute

      @name = context.args.name

      path = Pathname.new(name)
      path.rmtree if path.exist?

      send("execute_#{method}")
    end

    def validate_execute
      if context.options.plugin && context.options.component
        Cnfs.logger.warn('plugin and component are mutally exclusive options')
        return
      end
      true
    end

    def method
      return :plugin if context.options.plugin
      return :component if context.options.component
      :project
    end

    def execute_component
      generator.invoke_all
    end

    def execute_plugin
      generator.invoke_all
    end

    def execute_project
      # generator.destination_root = name
      generator.invoke_all
      return unless context.options.guided

      Cnfs.data_store.setup
      # TODO: This API has changed
      # CnfsCli.load_configurations(path: context.args.name, load_nodes: false)

      # Start a view here
      # TODO: This should create a node which should create a file with the yaml or a directory
      Project.new(name: context.args.name).create
    end

    def generator
      gen = "New::#{method.to_s.classify}Generator".constantize.new([context, name], context.options)
      gen.destination_root = name
      gen
    end
  end
end
