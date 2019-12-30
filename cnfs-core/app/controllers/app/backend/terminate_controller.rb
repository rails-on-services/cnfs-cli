# frozen_string_literal: true

module App::Backend
  class TerminateController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      runtime.terminate(request)
    end
  end
end
