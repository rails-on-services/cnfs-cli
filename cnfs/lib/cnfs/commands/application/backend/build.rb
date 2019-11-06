# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Build < Cnfs::Command
    attr_accessor :options, :services, :platform

    after_execute :publish_results

    # TODO: Use a method that returns a Cnfs::Core::Platform class rather than direct access to Cnfs.platform
    # so that any instance of that class can be returned
    def initialize(services, options) #, platform = Cnfs.platform)
      @services = services
      @options = options
      # @platform = platform
      type = :compose
      self.class.include(self.class.registrations[type]) if self.class.registrations[type]
    end
 
    # def echo; output.puts 'hello from cli gem' end
    def publish_results
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
