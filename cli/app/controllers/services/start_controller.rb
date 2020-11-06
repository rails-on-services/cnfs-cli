# frozen_string_literal: true

module Services
  class StartController < ApplicationController
    def execute
      run(:build) if options.build
      # context.runtime.clean if context.options.clean
      application.start
    end
  end
end
