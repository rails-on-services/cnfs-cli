# frozen_string_literal: true

module Resources
  class RuntimeController
    include ExecHelper
    include ResourcesHelper

    def connect
      binding.pry
    end

    def instance_shell
      system("ssh -A #{args.ip}")
      # unless service.shell_command
      #   raise Cnfs::Error, "#{service.name} does not implement the shell command"
      # end

      # system(*service.shell.take(2))
    end
  end
end
