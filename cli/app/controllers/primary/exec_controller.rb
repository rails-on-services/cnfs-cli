# frozen_string_literal: true

module Primary
  class ExecController < ApplicationController
    cattr_reader :command_group, default: :service_runtime

    def execute
      before_execute_on_target
      execute_on_target
    end

    def execute_on_target
      context.runtime.exec(context.service.name, context.args.command_args.join(' '), true).run!
    end
  end
end
