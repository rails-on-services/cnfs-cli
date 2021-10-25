# frozen_string_literal: true

module Services
  class StartController
    include ServicesHelper

    # TODO: Modify to take tags and profiles
    # TODO: The command should return output
    # The controller should resuce/raise any excpetions

    # Invoked against filtered services by default
    # To run against all available services pass it in to the method
    # context.runtime(services: context.services).start
    def execute
      context.runtime.start do |queue|
        queue.run
        queue.map(&:to_a).flatten.each do |msg|
          Cnfs.logger.warn(msg)
        end
      end
      rs = context.runtime.running_services(format: '{{.Names}}', status: :running) #, **filters)
      binding.pry
    end

    def old_execute
      # queue = CommandQueue.new
      each_runtime do |runtime, runtime_services|
        runtime.start(runtime_services)
        runtime_services(&:start)
        binding.pry
        queue.execute_all
        # queue.all.each do |command|
        #   command.execute
        # end
        # TODO: if the cmd_array has meta with the service command to invoke and this is in a command class
        # Then the class could auto invoke the command which triggers any callbacks
        # result = command.run!(*cmd_array)
        # raise Cnfs::Error, result.err if result.failure?

        # runtime_services.each do |service|
        #   # Trigger the service's after_start callbacks which may add commands to the service's command_queue
        #   service.start
        #   service.command_queue.each do |cmd_array|
        #     Cnfs.logger.debug cmd_array
        #     result = command.run!(*cmd_array)
        #     Cnfs.logger.error(result.err) if result.failure?
        #   end
        # end
      end
    end
  end
end
