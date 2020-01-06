# frozen_string_literal: true

module Primary
  class ShellController < ApplicationController
    def execute
      each_target do
        # before_execute_on_target
        call(:build) if options.build
        execute_on_target
      end
    end

    def execute_on_target
      runtime.exec(request.last_service_name, :bash, true).run!
    end
  end
end
