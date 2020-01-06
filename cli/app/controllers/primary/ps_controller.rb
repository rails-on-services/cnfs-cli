# frozen_string_literal: true

module Primary
  class PsController < ApplicationController
    def execute
      # with_selected_target do
      each_target do |target|
        # before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      # Dir.chdir(target.exec_path)  do
        output.puts runtime.services(format: format, status: status)
      # end
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
