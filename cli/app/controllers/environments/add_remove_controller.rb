# frozen_string_literal: true

module Environments
  class AddRemoveController
    include ExecHelper

    def execute(action)
      @args = Thor::CoreExt::HashWithIndifferentAccess.new(args)
      generator = EnvironmentGenerator.new([args.name], options)
      generator.behavior = action
      generator.invoke_all
    end
  end
end
