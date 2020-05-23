# frozen_string_literal: true

module Backend
  class NewController # < ApplicationController
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    def execute
      generator = NewGenerator.new([name], options)
      generator.destination_root = Pathname.new(Dir.pwd).join(name)
      generator.invoke_all
    end
  end
end
