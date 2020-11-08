# frozen_string_literal: true

module Namespaces
  class GenerateController < ApplicationController
    def execute
      Cnfs.silence_output(response.suppress_output) do
        application.generate_runtime_configs!
      end
    end
  end
end
