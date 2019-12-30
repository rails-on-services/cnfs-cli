# frozen_string_literal: true

module App::Backend
  class StartController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        call(:build) if options.build
        execute_on_target
        post_start_options
      end
    end

    def execute_on_target
      runtime.start(request)
    end
  end
end
