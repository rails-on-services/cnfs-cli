# frozen_string_literal: true

module Primary
  class StartController < ApplicationController
    cattr_reader :command_group, default: :service_admin

    def execute
      context.each_target do
        before_execute_on_target
        call(:build, target) if context.options.build
        execute_on_target
        post_start_options
      end
    end

    def execute_on_target
      context.runtime.clean if context.options.clean
      context.runtime.start.run!
    end
  end
end
