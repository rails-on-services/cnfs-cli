# frozen_string_literal: true

module Primary
  class RedeployController < ApplicationController
    cattr_reader :command_group, default: :cluster_runtime

    def execute
      context.each_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      context.runtime.redeploy.run!
    end
  end
end
