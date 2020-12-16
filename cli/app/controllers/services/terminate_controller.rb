# frozen_string_literal: true

module Services
  class TerminateController
    include ServicesHelper
    attr_accessor :services

    def execute
      each_runtime do |runtime, runtime_services|
        cmd_array = runtime.terminate(runtime_services).each do |cmd_array|
          # TODO: if the cmd_array has meta with the service command to invoke and this is in a command class
          # Then the class could auto invoke the command which triggers any callbacks
          result = command.run!(*cmd_array)
          raise Cnfs::Error, result.err if result.failure?
        end

        runtime_services.each do |service|
          # Trigger the service's after_start callbacks which may add commands to the service's command_queue
          service.terminate
          service.command_queue.each do |cmd_array|
            Cnfs.logger.debug cmd_array
            result = command.run!(*cmd_array)
            Cnfs.logger.error(result.err) if result.failure?
          end
        end
      end
      # project.runtime.terminate(services).each do |cmd_array|
      #   command.run(*cmd_array)
      # end
    end
  end
end
