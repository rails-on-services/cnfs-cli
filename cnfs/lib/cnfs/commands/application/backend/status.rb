# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Status < Cnfs::Command
    attr_accessor :options, :result, :display

    after_execute :show_results

    def initialize(options)
      @options = options
    end

    def show_results; output.puts(display)
      require 'tty-table'
      header = ['Platform Services', 'Status', 'Core Services', 'Status_', 'Infra Services', 'Status__']
      table = TTY::Table.new(header: header, rows: result)

output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0]) do |renderer|
  renderer.border do
    mid          '='
    mid_mid      ' '
  end
end
      # output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0])
    end
  end
end
