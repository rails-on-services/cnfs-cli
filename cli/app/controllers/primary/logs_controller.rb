# frozen_string_literal: true

module Primary
  class LogsController < ApplicationController
    cattr_reader :command_group, default: :service_runtime

    def execute
      trap('SIGINT') { throw StandardError } if context.options.tail
      before_execute_on_target
      execute_on_target
    rescue StandardError
    end

    def execute_on_target
      context.runtime.logs(context.service.name).run!
    end
  end
end
