# frozen_string_literal: true

module Environments
  class AddRemoveController < ApplicationController
    attr_accessor :options, :arguments

    def initialize(options:, arguments:)
      Cnfs.require_deps
      Cnfs.require_project!(arguments: {}, options: options, response: nil)
      @options = options.merge(project_name: Cnfs.project.class.module_parent.name.downcase)
      @arguments = Thor::CoreExt::HashWithIndifferentAccess.new(arguments)
    end

    def execute(action)
      generator = EnvironmentGenerator.new([arguments.name], options)
      generator.behavior = action
      generator.invoke_all
    end
  end
end
