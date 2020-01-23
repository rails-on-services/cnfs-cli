# frozen_string_literal: true

module Primary
  class CreateController < ApplicationController
    def execute
      each_target do |_target|
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      return unless valid_action?(:create) && valid_namespace?

      runtime.create.run!
    end
  end
end
