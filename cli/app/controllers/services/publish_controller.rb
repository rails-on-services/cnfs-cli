# frozen_string_literal: true

module App::Backend
  class PublishController < Cnfs::Command
    on_execute :execute_command

    def execute_command; end
  end
end
