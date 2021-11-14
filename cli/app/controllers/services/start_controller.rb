# frozen_string_literal: true

module Services
  class StartController
    include ServicesHelper

    before_execute :raise_if_runtimes_empty

    # TODO: Modify to take tags and profiles
    # TODO: The command should return output
    # The controller should resuce/raise any excpetions

    # Invoked against filtered services by default
    # To run against all available services pass it in to the method
    # context.resource_runtime(services: context.services).map(&:start)
    def execute
      run_callbacks :execute do
        context.resource_runtimes.each do |runtime|
          runtime.start do |queue|
            binding.pry
            queue.run
            queue.map(&:to_a).flatten.each do |msg|
              Cnfs.logger.warn(msg)
            end
          end
        end
      end
    end
  end
end
