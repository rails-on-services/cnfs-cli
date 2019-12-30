# frozen_string_literal: true

module App::Backend
  class PsController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      output.puts runtime.services(format: format, status: status)
    end

    # TODO: format and status are specific to the runtime so refactor when implementing skaffold
    def format
      return nil unless options.format

      if options.format.eql?('mounts')
        "table {{.ID}}\t{{.Mounts}}"
      end
    end

    # created, restarting, running, removing, paused, exited, or dead
    def status
      options.status || :running
    end
  end
end
