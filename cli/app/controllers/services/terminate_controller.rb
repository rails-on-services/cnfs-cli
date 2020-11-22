# frozen_string_literal: true

module Services
  class TerminateController
    include ServicesHelper
    attr_accessor :services

    def execute
      project.runtime.terminate(services).each do |cmd_array|
        command.run(*cmd_array)
      end
    end
  end
end
