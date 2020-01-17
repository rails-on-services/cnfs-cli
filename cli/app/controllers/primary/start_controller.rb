# frozen_string_literal: true

module Primary
  class StartController < ApplicationController
    def execute
      each_target do |target|
        before_execute_on_target
        call(:build) if options.build
        execute_on_target
        post_start_options
      end
    end

    def execute_on_target
      runtime.clean if options.clean
        # binding.pry
      runtime.start.run!
    end
  end
end
