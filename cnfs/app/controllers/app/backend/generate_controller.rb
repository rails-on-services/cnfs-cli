# frozen_string_literal: true

module App::Backend
  class GenerateController < Cnfs::Command
    def execute
      each_target do |target|
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      generator = DeploymentGenerator.new(args, options)
      generator.deployment = deployment
      generator.target = target
      generator.invoke_all
    end
  end
end
