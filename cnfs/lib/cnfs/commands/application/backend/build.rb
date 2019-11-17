# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Build < Cnfs::Command

    before_execute :generate_manifests
    after_execute :publish_results

    def publish_results
      # binding.pry
      return unless errors.size.positive?
      # output.puts(errors.messages.map{ |(k, v)| "#{v}\n" }) if errors.size.positive?
      # binding.pry
      require 'tty-table'
      # table = TTY::Table.new(['header1', 'header2'], [['a1', 'a2'], ['b1', 'b2']])
      table = TTY::Table.new(['Commands', 'Errors'], errors.messages.to_a)
      output.puts "\n"
      output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0])
      Kernel.exit(errors.size)
    end
  end
end
