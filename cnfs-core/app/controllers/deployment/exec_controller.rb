# frozen_string_literal: true

module App::Backend
  class ExecController < Cnfs::Command
    def execute
      command = args.pop
      with_selected_target do
        before_execute_on_target
        execute_on_target(command)
      end
    end

    def execute_on_target
      runtime.exec(request.last_service_name, command)
    end
  end
end
