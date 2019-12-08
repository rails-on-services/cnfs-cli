# frozen_string_literal: true

module App::Backend
  class AttachController < Cnfs::Command

    on_execute :execute_command

    def execute_command
      binding.pry
    end
  end
end
