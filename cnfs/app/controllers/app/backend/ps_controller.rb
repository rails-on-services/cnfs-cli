# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Ps < Cnfs::Command
    on_execute :get_services
    after_execute :show_results

    def get_services
      # binding.pry
      # created, restarting, running, removing, paused, exited, or dead
      # TODO: The label names will be standard when generated with cnfs CLI
      @display = services(status: options.status || :running, platform_name: :cnfs) # , status: :exited)
    end

    def show_results
      # output.puts services(status: :running)
      # output.puts services(format: "table {{.ID}}\t{{.Mounts}}", status: :running)
      # output.puts services(format: nil, status: :exited)
      # output.puts services # (format: nil, status: :exited)
      output.puts(display)

      # next_command(:status).new(params, options, config.to_h.merge(command: 'Status')).execute if options.status
      execute(:status) if options.verbose
    end
  end
end
