# frozen_string_literal: true

module Hendrix
  class MainCommand < ApplicationCommand
    desc 'generate', 'generate'
    def generate(_type, *_attributes) = execute

    desc 'console', 'console'
    def console() = execute
  end
end
