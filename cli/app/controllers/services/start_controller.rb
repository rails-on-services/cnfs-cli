# frozen_string_literal: true

module Services
  class StartController
    include ServicesHelper
    attr_accessor :services

    def execute
      result = command.run!(*project.runtime.start(services))
      raise Cnfs::Error, result.err if result.failure?
    end
  end
end
