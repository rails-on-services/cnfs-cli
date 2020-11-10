# frozen_string_literal: true

module Primary
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
        # add_backend if options.backend
        # add_cnfs if options.cnfs
      end
    end

    def add_environments
      %w[development staging production].each do |env|
        ComponentController.new([], options.merge(project_name: name)).environment(env)
        ComponentController.new([], options.merge(project_name: name, environment: env)).namespace('main')
      end
    end
  end
end
