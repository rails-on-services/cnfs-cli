# frozen_string_literal: true

module Primary
  class PsController < ApplicationController
    def execute
      each_target do |_target|
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

      "table {{.ID}}\t{{.Mounts}}" if options.format.eql?('mounts')
    end

    def status
      options.status || :running
    end
  end
end
