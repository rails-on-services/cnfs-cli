# frozen_string_literal: true

module Services
  class ShellController
    include ServicesHelper
    attr_accessor :service

    def execute
      unless service.shell_command
        raise Cnfs::Error, "#{service.name} does not implement the shell command"
      end

      system(*service.shell.take(2))
    end
  end
end
