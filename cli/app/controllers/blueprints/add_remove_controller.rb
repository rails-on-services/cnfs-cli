# frozen_string_literal: true

module Blueprints
  class AddRemoveController < ApplicationController
    attr_accessor :options, :arguments

    def initialize(options:, arguments:)
      @options = options
      @arguments = arguments
    end

    def execute(action)
      # generator = Component::EnvironmentGenerator.new([arguments.name], options)
      # generator.behavior = action
      # generator.invoke_all
      # NOTE: The blueprint generator is in the core gem, but the content is in the infra gem
      binding.pry
    end
  end
end
