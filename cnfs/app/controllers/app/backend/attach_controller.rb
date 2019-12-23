# frozen_string_literal: true

module App::Backend
  class AttachController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        call(:build) if options.build
        execute_on_target
      end
    end

    def execute_on_target
      runtime.attach(request)
    end
  end
end
