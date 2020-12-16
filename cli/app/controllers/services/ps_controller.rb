# frozen_string_literal: true

module Services
  class PsController
    include ServicesHelper

    def execute
      xargs = args.args.empty? ? {} : args.args
      each_runtime do |runtime, runtime_services|
        Cnfs.project.runtime.ps(**xargs)
        queue.execute_all
        # Cnfs.project.runtime = runtime
        # Cnfs.project.runtime.prepare
        # command.run(*Cnfs.project.runtime.ps(**xargs))
      end
      # list = project.runtime.ps(**xargs)
      # puts list
    end

    # TODO: format and status are specific to the runtime so refactor when implementing skaffold
    def format
      return nil unless options.format

      "table {{.ID}}\t{{.Mounts}}" if options.format.eql?('mounts')
    end

    def status
      options.status || :running
    end
  end
end
