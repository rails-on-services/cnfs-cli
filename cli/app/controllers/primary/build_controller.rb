# frozen_string_literal: true

module Primary
  class BuildController < ApplicationController
    def execute
      each_target do |target|
        # before_execute_on_target
        execute_on_target
      end
      if errors.size.positive?
        publish_results
        Kernel.exit(errors.size)
        post_start_options
      end
    end

    # def limits; { targets: 1 } end

    def execute_on_target
      return unless request.services.any?
      binding.pry

      # runtime.build.run!
    end
  end
end
