# frozen_string_literal: true

module App::Backend
  class RestartController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        call(:build) if options.build
        exectue_on_target
        post_start_options
      end
    end

    def execute_on_target
      runtime.restart(request)
    end
  end
end
