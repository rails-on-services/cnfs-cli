# frozen_string_literal: true

module Images
  class PullController < ApplicationController
    def execute
      binding.pry
      application.runtime.pull(application.services)
      # before_execute_on_target
      # execute_on_target
    end

    def execute_on_target
      context.runtime.pull.run!
    end
  end
end
