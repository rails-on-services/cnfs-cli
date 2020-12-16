# frozen_string_literal: true

module Services
  class ConsoleController
    include ServicesHelper
    attr_accessor :service

    def execute
      unless service.commands.key?(:console)
        raise Cnfs::Error, "#{service.name} does not implement the console command"
      end

      system(*service.console.take(2))
    end
  end
end
