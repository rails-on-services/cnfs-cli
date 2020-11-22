# frozen_string_literal: true

module Services
  class ConsoleController
    include ServicesHelper
    attr_accessor :service

    def execute
      unless service.respond_to?(:console_command)
        raise Cnfs::Error, "#{service.name} does not implement the console command"
      end

      command.run(*service.console)
    end
  end
end
