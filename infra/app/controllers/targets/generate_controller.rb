# frozen_string_literal: true

module Targets
  class GenerateController < ApplicationController
    cattr_reader :command_group, default: :service_manifest

    def execute
      context.each_target do |target|
        # before_execute_on_target
        unless target.infra_runtime
          output.puts "WARN: No infra_runtime configured for target '#{target.name}'"
          next
        end

        execute_on_target
      end
    end

    def execute_on_target
      generator = generator_class.new([], context.options)
      generator.context = context
      generator.invoke_all
    end

    def generator_class
      "InfraRuntime::#{context.target.infra_runtime.type.demodulize}Generator".safe_constantize
    end
  end
end
