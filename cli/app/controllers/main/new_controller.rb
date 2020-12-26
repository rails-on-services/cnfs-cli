# frozen_string_literal: true

module Main
  class NewController
    include ExecHelper
    include TtyHelper

    def execute
      FileUtils.rm_rf(args.name) if Dir.exist?(args.name)
      generator = ProjectGenerator.new([args.name], options)
      generator.destination_root = args.name
      generator.invoke_all
    end

    def configure
      %w[development staging production].each do |env|
        env = Environment.create(name: env)
        env.namespaces.create(name: 'main')
      end
      return unless options.guided

      prompt.say('Starting guided project configuration')
      require 'pry'
      args.blueprints.create
    end
  end
end
