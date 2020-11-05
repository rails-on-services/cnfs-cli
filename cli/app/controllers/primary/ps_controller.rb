# frozen_string_literal: true

module Primary
  class PsController < ApplicationController
    def execute
      response.output.puts application.runtime_services(format: format, status: status)
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
