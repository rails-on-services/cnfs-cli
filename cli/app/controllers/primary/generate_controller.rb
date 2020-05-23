# frozen_string_literal: true

module Primary
  class GenerateController < ApplicationController
    cattr_reader :command_group, default: :service_manifest

    def execute
      context.each_target do |_target|
        execute_on_target
      end
    end

    def execute_on_target
      FileUtils.rm(manifest.manifest_files) if context.options.clean
      generator = context.runtime_generator_class.new([], context.options)
      generator.context = context
      generator.invoke_all
    end

    # def generator_class
    #   "Runtime::#{context.target.runtime.type.demodulize}Generator".safe_constantize
    # end
  end
end
