# frozen_string_literal: true

module Component
  class NamespaceController < ApplicationController
    attr_accessor :options, :arguments

    def initialize(options:, arguments:)
      Cnfs.require_deps
      Cnfs.require_project!(arguments: {}, options: options, response: nil)
      @options = options.merge(project_name: Cnfs.project.class.module_parent.name.downcase)
      @arguments = arguments
    end

    def add
      generator = Component::NamespaceGenerator.new([arguments.name], options)
      generator.behavior = arguments.action
      generator.invoke_all
    end

    def remove
      add
    end
  end
end
