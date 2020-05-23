# frozen_string_literal: true

module Primary
  class PsController < ApplicationController
    cattr_reader :command_group, default: :cluster_runtime

    def execute
      context.each_target do |_target|
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      context.output.puts context.runtime.services(format: format, status: status)
    end

    # TODO: format and status are specific to the runtime so refactor when implementing skaffold
    def format
      return nil unless context.options.format

      "table {{.ID}}\t{{.Mounts}}" if context.options.format.eql?('mounts')
    end

    def status
      context.options.status || :running
    end
  end
end
