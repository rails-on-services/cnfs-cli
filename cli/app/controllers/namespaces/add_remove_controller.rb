# frozen_string_literal: true

module Namespaces
  class AddRemoveController < ApplicationController
    include ExecHelper

    def execute
      @args = Thor::CoreExt::HashWithIndifferentAccess.new(args)
      generator = NamespaceGenerator.new([args.name], options)
      generator.behavior = options.behavior
      generator.invoke_all
    end
  end
end
