# frozen_string_literal: true

module Rails
  class GenerateController < ApplicationController
    # NOTE: For now this controller can only generate a service
    def execute
      ServiceGenerator.new([args.service_name], options).invoke_all
    end
  end
end
