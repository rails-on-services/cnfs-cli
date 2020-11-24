# frozen_string_literal: true

module Infra
  class ApplyController
    #include ExecHelper
    include EnvironmentsHelper

    def execute
      binding.pry
    end

    def execute_on_target
      Dir.chdir(project.write_path(:templates)) do
        binding.pry
        # context.runtime.init.run! if context.options.init
        # # system_cmd('rm -f .terraform/terraform.tfstate')
        # context.runtime.apply.run!
        # system_cmd('terraform output -json > output.json', cmd_environment)
        # show_json
      end
    end
  end
end
