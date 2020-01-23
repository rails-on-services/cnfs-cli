# frozen_string_literal: true

module Primary
  class GenerateController < ApplicationController
    def execute
      each_target do |_target|
        execute_on_target
      end
    end

    def execute_on_target
      FileUtils.rm(manifest_files) if options.clean
      generator = generator_class.new([], options)
      generator.deployment = target.deployment
      generator.target = target
      generator.application = target.application
      generator.write_path = Pathname.new(target.write_path(:deployment))
      generator.invoke_all
    end

    def generator_class
      "Runtime::#{target.runtime.type.demodulize}Generator".safe_constantize
    end
  end
end
