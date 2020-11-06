# frozen_string_literal: true

module Primary
  class CreateController < ApplicationController
    cattr_reader :command_group, default: :cluster_admin

    def execute
      context.each_target do |_target|
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      context.runtime.create.run!
    end
  end
end
