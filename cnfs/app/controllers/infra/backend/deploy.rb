# frozen_string_literal: true

module Cnfs::Commands::Infra
  class Backend::Deploy < Cnfs::Command
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options
    end

    def execute(input: $stdin, output: $stdout)
      binding.pry
      # Command logic goes here ...
      output.puts "INFRA OK"
    end
  end
end
