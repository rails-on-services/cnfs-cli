# frozen_string_literal: true

module Primary
  class ShellController < ApplicationController
    cattr_reader :command_group, default: :service_runtime

    def execute
      before_execute_on_target
      call(:build, context.target) if context.options.build
      execute_on_target
    end

    def execute_on_target
      context.runtime.exec(context.service.name, :bash, true).run!
    end
  end
end
