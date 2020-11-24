# frozen_string_literal: true

module Infra
  class GenerateController
    include InfraHelper

    # Empty method b/c it is handled by InfraHelper#before_execute
    def execute
      # infra_runtime.generate
    end
  end
end
