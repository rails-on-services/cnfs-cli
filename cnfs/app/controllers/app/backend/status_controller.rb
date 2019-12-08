# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Status < Cnfs::Command
    after_execute :show_results

    def show_results
      output.puts(display)
      # binding.pry
      require 'tty-table'
      header = ['Platform Services', 'Status', 'Core Services', 'Status_', 'Infra Services', 'Status__']
      table = TTY::Table.new(header: header, rows: result)

output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0]) do |renderer|
  renderer.border do
    mid          '='
    mid_mid      ' '
  end
end
output.puts "Environment: #{config.platform.env}\tProfile: #{config.platform.profile}\tFeature Set: #{config.platform.feature_set}"
      # output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0])
    end
  end
end
