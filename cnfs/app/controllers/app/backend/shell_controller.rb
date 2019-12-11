# frozen_string_literal: true

module App::Backend
  class ShellController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        call(:build) if options.build
        exectue_on_target
      end
    end

    def execute_on_target
      runtime.exec(request.last_service_name, :bash)
    end
  end
end
