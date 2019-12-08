# frozen_string_literal: true

module App::Backend
  class GenerateController < Cnfs::Command
    def execute
      generator = DeploymentGenerator.new(args, options)
      generator.deployment = deployment
      generator.invoke_all
    end
  end
end
