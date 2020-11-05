# frozen_string_literal: true

module Infra
  class GenerateController < ApplicationController
    def execute
      unless infra_runtime
        raise Cnfs::Error, "No infra_runtime configured for environment '#{application.environment.name}'"
      end

      generator = generator_class.new([], options)
      generator.context = application
      generator.invoke_all
    end

    def generator_class
      "InfraRuntime::#{infra_runtime.type.demodulize}Generator".safe_constantize
    end

    def infra_runtime
      application.environment.infra_runtime
    end
  end
end
