# frozen_string_literal: true

module App::Backend
  class CreateController < Cnfs::Command
    def execute
      each_target do |target|
        before_execute_on_target
        execute_on_target
      end
      each_target do |target|
        call(:status)
      end
    end

    def execute_on_target
      runtime.create(request)
    end
  end
end
