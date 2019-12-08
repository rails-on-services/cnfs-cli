# frozen_string_literal: true

module App::Backend
  class PsController < Cnfs::Command

    def execute
      # TODO: get target code into base class
      output.puts target.runtime.services
      execute(:status) if options.verbose
    end

    def get_services
      # created, restarting, running, removing, paused, exited, or dead
      @display = target.runtime.services(status: options.status || :running) # status: :exited)
    end

    def show_results
      # output.puts runtime.services(status: :running)
      # output.puts runtime.services(format: "table {{.ID}}\t{{.Mounts}}", status: :running)
      # output.puts runtime.services(format: nil, status: :exited)
      output.puts runtime.services # (format: nil, status: :exited)
      # output.puts(display)

      # next_command(:status).new(params, options, config.to_h.merge(command: 'Status')).execute if options.status
      execute(:status) if options.verbose
    end
  end
end
