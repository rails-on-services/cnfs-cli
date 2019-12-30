# frozen_string_literal: true

module App::Backend
  class LogsController < Cnfs::Command
    def execute
      trap('SIGINT') { throw StandardError } if options.tail
      with_selected_target do
        before_execute_on_target
        execute_on_target
      end
    rescue StandardError
    end

    def execute_on_target
      runtime.logs(request.last_service_name)
    end
  end
end
