# frozen_string_literal: true

module Services
  class StartController
    include ServicesHelper
    attr_accessor :services

    # controller asks context for targets
    # context asks component for targets
    # namespace returns [target]
    # target returns [self]
    # environment returns targets
    # OR
    # any component can have activated services
    # components can be in any order so have to ask context for targets
    def exec_services
      Cnfs.context.services.each do |service|
      end
    end

    def new_execute
      Cnfs.context.targets.each do |target|
        target.services.each do |service|
          target.runtime.start(service)
        end
      end
    end

    def execute
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
