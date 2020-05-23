# frozen_string_literal: true

class InitController # < ApplicationController
  attr_accessor :name, :options

  def initialize(name, options)
    @name = name
    @options = options
  end

  def execute
    generator = InitGenerator.new([name], options)
    generator.destination_root = options.init ? Pathname.new(Dir.pwd) : Pathname.new(Dir.pwd).join(name)
    generator.invoke_all
  end
end
