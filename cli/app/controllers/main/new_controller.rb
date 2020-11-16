# frozen_string_literal: true

module Main
  class NewController
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    def execute
      generator = NewGenerator.new([name], options)
      generator.destination_root = name
      generator.invoke_all

      Dir.chdir(name) do
        Cnfs.reset
        add_environments
      end
    end

    def add_environments
      %w[development staging production].each do |env|
        EnvironmentsController.new([], options.merge(project_name: name)).add(env)
        NamespacesController.new([], options.merge(project_name: name, environment: env)).add('main')
      end
    end
  end
end
