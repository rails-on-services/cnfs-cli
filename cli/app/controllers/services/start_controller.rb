# frozen_string_literal: true

module Services
  class StartController
    include ServicesHelper
    attr_accessor :services

    def execute
      # command.run(*project.runtime.start(services))
    end
  end
end
