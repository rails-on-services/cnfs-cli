# frozen_string_literal: true

module Infra
  class DestroyController

    def execute
      run_in_path(:destroy) do |result|
        binding.pry
      end
    end
  end
end
