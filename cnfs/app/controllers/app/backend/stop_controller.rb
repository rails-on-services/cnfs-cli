# frozen_string_literal: true

module App::Backend
  class StopController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        exectue_on_target
      end
    end

    def execute_on_target
      runtime.stop(request)
    end
  end
end
