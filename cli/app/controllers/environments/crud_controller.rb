# frozen_string_literal: true

module Environments
  class CrudController
    include ExecHelper
    include TtyHelper

    def create
      Environment.create(name: args.name)
    end

    def delete
      Environment.find_by(name: args.name)&.destroy
    end

    def describe
      return unless (environment = Environment.find_by(name: args.name))

      puts environment.as_save.except(:name)
    end

    def list
      puts Environment.order(:name).pluck(:name).join("\n")
      true
    end

    def update
      return unless (env = Environment.find_by(name: args.name))

      # TODO: Test below. this should not be necessary
      result = Environments::View.new.render(env)
      env.update(result)
    end

    # TODO: Remove this code and generators
    # Used by Main::NewController
    # def add
    #   Environment.create(name: args.name)
    #   # generator = EnvironmentGenerator.new([args.name], options)
    #   # generator.behavior = args.behavior if args.behavior
    #   # generator.invoke_all
    # end
  end
end
