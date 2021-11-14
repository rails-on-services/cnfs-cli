# frozen_string_literal: true

module Services
  class ConsoleController
    include ServicesHelper
    attr_accessor :service

    def execute
      raise Cnfs::Error, "#{service.name} does not implement the console command" unless service.commands.key?(:console)

      system(*service.console.take(2))
    end
  end
end
