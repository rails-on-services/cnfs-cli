# frozen_string_literal: true

module Main
  class NewController
    include ExecHelper

    def execute
      FileUtils.rm_rf(args.name) if Dir.exist?(args.name)
      generator = ProjectGenerator.new([args.name], options)
      generator.destination_root = args.name
      generator.invoke_all

      Dir.chdir(args.name) do
        Cnfs.reset
        add_environments
      end
    end

    def add_environments
      %w[development staging production].each do |env|
        EnvironmentsController.new([], options).add(env)
        NamespacesController.new([], options.merge(environment: env)).add('main')
      end
    end
  end
end
