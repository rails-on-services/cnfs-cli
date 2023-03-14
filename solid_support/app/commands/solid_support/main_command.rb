# frozen_string_literal: true

module SolidSupport
  class MainCommand < ApplicationCommand
    desc 'generate', 'generate'
    def generate(_type, *_attributes) = execute

    desc 'console', 'console'
    def console() = execute
  end
end
