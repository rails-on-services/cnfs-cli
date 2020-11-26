# frozen_string_literal: true

module Infra
  class ShellController
    include ExecHelper
    # include InfraHelper

    def execute
      system("ssh -A #{args.ip}")
      # unless service.shell_command
      #   raise Cnfs::Error, "#{service.name} does not implement the shell command"
      # end

      # system(*service.shell.take(2))
    end
  end
end
