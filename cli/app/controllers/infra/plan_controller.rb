# frozen_string_literal: true

module Infra
  class PlanController
    include InfraHelper

    def execute
      run_in_path(:init)
      run_in_path(:plan) do |result|
        raise Cnfs::Error, result.err if result.failure?
      end
    end
  end
end
