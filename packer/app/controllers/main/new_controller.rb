# frozen_string_literal: true

module Main
  class NewController
    include ExecHelper

    def execute
      generator = NewGenerator.new([args.name], options)
      generator.destination_root = args.name
      generator.invoke_all
    end
  end
end
