# frozen_string_literal: true

module Services
  class RestartController
    include ServicesHelper
    attr_accessor :services

    def execute
      project.runtime.restart(services).each_with_index do |cmd_array, index|
        result = command.run!(*cmd_array)
        raise Cnfs::Error, result.err if result.failure?

        state = index.zero? ? :stopped : :started
        services.each do |service|
          service.update_state(state).each do |cmd_array|
            result = command.run!(*cmd_array)
            Cnfs.logger.error(result.err) if result.failure?
          end
        end
      end
    end
  end
end
