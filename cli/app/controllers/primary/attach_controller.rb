# frozen_string_literal: true

module Primary
  class AttachController < ApplicationController
    def execute
      each_target do
        before_execute_on_target
        call(:build) if options.build
        execute_on_target
      end
    end

    def execute_on_target
      runtime.attach.run!
    end
  end
end
