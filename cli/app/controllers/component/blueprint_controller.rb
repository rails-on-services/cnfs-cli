# frozen_string_literal: true

module Component
  class BlueprintController < ApplicationController
    attr_accessor :options, :arguments

    def initialize(options:, arguments:)
      @options = options
      @arguments = arguments
    end

    def add
      # NOTE: The blueprint generator is in the core gem, but the content is in the infra gem
      binding.pry
    end

    def remove
      binding.pry
    end
  end
end
