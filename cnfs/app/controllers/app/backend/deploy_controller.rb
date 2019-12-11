# frozen_string_literal: true

module App::Backend
  class DeployController < Cnfs::Command
    def execute
      each_target do |target|
        before_execute_on_target
        execute_on_target
      end
      each_target do |target|
        call(:status)
      end
    end

    def execute_on_target
      # command(command_options).run!(target.runtime.deploy(services), cmd_options)
      runtime.deploy(request)
    end
  end
end
