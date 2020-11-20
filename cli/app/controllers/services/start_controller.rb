# frozen_string_literal: true

module Services
  class StartController
    include ExecHelper

    def execute
      services = project.services.where(name: arguments.services)
      # binding.pry
      run(:build) if options.build
      puts runtime.start(services)
      # # context.runtime.clean if context.options.clean
    end
  end
end
