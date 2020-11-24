# frozen_string_literal: true

module Infra
  class PlanController
    include InfraHelper

    def execute
      # project.path(to: :templates).mkpath
      Dir.chdir(project.path(to: :templates)) do
        cmd_array = project.environment.infra_runtime.plan
        result = command.run!(*cmd_array)
        raise Cnfs::Error, result.err if result.failure?
      end
    end
  end
end
