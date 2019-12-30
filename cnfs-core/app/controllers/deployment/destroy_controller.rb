# frozen_string_literal: true

module App::Backend
  class DestroyController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      runtime.destroy(request)
    end
  end
end
