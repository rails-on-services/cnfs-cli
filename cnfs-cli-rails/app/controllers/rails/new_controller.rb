# frozen_string_literal: true

module Rails
  class NewController < ApplicationController
    def execute
      generator = NewGenerator.new([args.project_name], options)
      generator.destination_root = args.project_name
      generator.invoke_all
    end
  end
end
