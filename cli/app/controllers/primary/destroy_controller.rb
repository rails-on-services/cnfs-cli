# frozen_string_literal: true

module Primary
  class DestroyController < ApplicationController
    def execute
      each_target do
        # before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      runtime.destroy
      run!
    end
  end
end
