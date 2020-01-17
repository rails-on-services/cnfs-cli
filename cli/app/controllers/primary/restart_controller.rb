# frozen_string_literal: true

module Primary
  class RestartController < ApplicationController
    def execute
      each_target do
        before_execute_on_target
        call(:build) if options.build
        execute_on_target
        post_start_options
      end
    end

    def execute_on_target
      runtime.restart.run!
    end
  end
end
