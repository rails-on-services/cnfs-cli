# frozen_string_literal: true

module Services
  class StartController
    include ServicesHelper
    attr_accessor :services

    def execute
      cmd_array = project.runtime.start(services)
      result = command.run!(*cmd_array)
      raise Cnfs::Error, result.err if result.failure?

      services.each { |service| service.update_state(:started) }
    end
  end
end
