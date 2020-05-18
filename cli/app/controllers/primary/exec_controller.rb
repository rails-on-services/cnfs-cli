# frozen_string_literal: true

module Primary
  class ExecController < ApplicationController
    def execute_on_target
      runtime.exec(request.last_service_name, args.command_name, true).run!
    end
  end
end
