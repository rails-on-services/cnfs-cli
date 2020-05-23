# frozen_string_literal: true

module Targets
  class InitController < ApplicationController
    def execute
      each_target do |_target|
        # NOTE: do not run before_execute_on_target since the target namespace doesn't exit in kubeconfig
        execute_on_target
      end
    end

    def execute_on_target
      response.add(exec: target.init(options), pty: true).run!
      response.add(exec: 'kubectl cluster-info', pty: true).run!
    end
  end
end
