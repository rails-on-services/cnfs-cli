# frozen_string_literal: true

module Targets
  class ApplyController < ApplicationController
    def execute
      each_target do |target|
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      binding.pry
      # generate_config if stale_config
      Dir.chdir(target.write_path(:infra)) do
        # system_cmd('rm -f .terraform/terraform.tfstate')
        runtime.init
        runtime.apply
        # system_cmd('terraform output -json > output.json', cmd_environment)
        # show_json
      end
    end
  end
end

