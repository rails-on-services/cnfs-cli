# frozen_string_literal: true

module Targets
  class InitController < ApplicationController
    def execute
      each_target do |target|
        # before_execute_on_target

        execute_on_target
      end
    end

    def execute_on_target
      response.add(exec: target.init(options)).run!
      response.add(exec: 'kubectl cluster-info').run!
    end
  end
end
