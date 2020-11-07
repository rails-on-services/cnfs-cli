# frozen_string_literal: true

module Services
  class PullController < ApplicationController
    cattr_reader :command_group, default: :image_operations

    def execute
      before_execute_on_target
      execute_on_target
    end

    def execute_on_target
      context.runtime.pull.run!
    end
  end
end
