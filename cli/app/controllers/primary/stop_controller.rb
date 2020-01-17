# frozen_string_literal: true

module Primary
  class StopController < ApplicationController
    def execute
      each_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      runtime.stop.run!
    end
  end
end
