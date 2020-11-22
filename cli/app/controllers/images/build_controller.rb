# frozen_string_literal: true

module Images
  class BuildController
    include ExecHelper
    include TtyHelper

    def execute
      services = project.services.where(name: args.services)
      command.run(*project.runtime.build(services))
    end
  end
end
