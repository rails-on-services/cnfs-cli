# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Ps < Cnfs::Command
    attr_accessor :options, :result, :display

    after_execute :show_results

    def initialize(options)
      @options = options
    end

    def show_results; output.puts(display) end
  end
end
