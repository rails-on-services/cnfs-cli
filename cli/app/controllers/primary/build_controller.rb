# frozen_string_literal: true

module Primary
  class BuildController < ApplicationController
    cattr_reader :command_group, default: :image_operations

    def execute
      # context.each_target do |_target|
        before_execute_on_target
        execute_on_target
    end

    def blah
      # end

      if errors.size.positive?
        publish_results
        # TODO: The way to exit is by raising an error to be captured by the exe runner
        Kernel.exit(errors.size)
        post_start_options
      end
    end

    def execute_on_target
      # return unless request.services.any?

      context.runtime.build.run!
    end
  end
end
