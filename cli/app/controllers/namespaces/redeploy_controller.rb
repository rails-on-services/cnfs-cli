# frozen_string_literal: true

module Namespaces
  class RedeployController
    include ExecHelper
    include TtyHelper

    def execute
      project.runtime.redeploy.each do |cmd_array|
        command.run(*cmd_array)
      end
    end
  end
end
