# frozen_string_literal: true

module Services
  class StopController
    include ServicesHelper
    attr_accessor :services

    def execute
      command.run(*project.runtime.restart(services))
    end
  end
end
