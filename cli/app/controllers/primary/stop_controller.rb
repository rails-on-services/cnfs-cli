# frozen_string_literal: true

module Primary
  class StopController < ApplicationController
    cattr_reader :command_group, default: :service_admin

    def execute
      context.each_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      context.runtime.stop.run!
    end
  end
end
