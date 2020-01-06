# frozen_string_literal: true

module Primary
  class LogsController < ApplicationController
    def execute
      trap('SIGINT') { throw StandardError } if options.tail
      each_target do
      # with_selected_target do
        # before_execute_on_target
        execute_on_target
      end
    rescue StandardError
    end

    def execute_on_target
      runtime.logs(request.last_service_name)
      run!
    end
  end
end
