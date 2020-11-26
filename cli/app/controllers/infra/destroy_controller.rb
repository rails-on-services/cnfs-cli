# frozen_string_literal: true

module Infra
  class DestroyController
    include InfraHelper

    def execute
      run_in_path(:destroy) do |result|
        raise Cnfs::Error, result.err if result.failure?
      end
    end
  end
end
