# frozen_string_literal: true

module Primary
  class RestartController < ApplicationController
    cattr_reader :command_group, default: :service_admin

    def execute
      context.each_target do
        before_execute_on_target
        # call(:build) if options.build
        execute_on_target
        post_start_options
      end
    end

    def execute_on_target
      context.runtime.restart.run!
    end
  end
end
