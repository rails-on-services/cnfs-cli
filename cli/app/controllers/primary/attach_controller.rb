# frozen_string_literal: true

module Primary
  class AttachController < ApplicationController
    cattr_reader :command_group, default: :service_runtime

    def execute
      before_execute_on_target
      call(:build, context.target) if context.options.build
      execute_on_target
    end

    def execute_on_target
      context.runtime.attach.run!
    end
  end
end
