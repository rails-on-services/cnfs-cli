# frozen_string_literal: true

module Targets
  class ApplyController < ApplicationController
    cattr_reader :command_group, default: :service_manifest

    def execute
      context.each_target do |_target|
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      Dir.chdir(context.write_path(:infra)) do
        context.runtime.init.run! if context.options.init
        # system_cmd('rm -f .terraform/terraform.tfstate')
        context.runtime.apply.run!
        # system_cmd('terraform output -json > output.json', cmd_environment)
        # show_json
      end
    end
  end
end
