# frozen_string_literal: true

module Namespaces
  class DestroyController
    include ExecHelper
    include TtyHelper

    def execute
      command.run(*project.runtime.destroy)
    end
  end
end
