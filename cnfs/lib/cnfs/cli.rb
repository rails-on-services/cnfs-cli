# frozen_string_literal: true

module Cnfs
  class Errors
    attr_reader :messages, :details

    def initialize
      @messages = {}
      @details = {}
    end

    def add(attribute, message = :invalid, options = {})
      @messages[attribute] = message
      @details[attribute] = options
    end

    def size; @messages.size end
  end

  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    # Global commands
    desc 'version', 'cnfs version'
    map %w(--version -v) => :version
    def version
      puts "v#{Cnfs::VERSION}"
    end

    desc 'console', 'Start a command console (short-cut alias: "c")'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    def console(*)
      if options[:help]
        invoke :help, ['console']
      else
        ConsoleController.new(options).execute
      end
    end

    # Load sub-commnds
    # register Cnfs::Commands::ApplicationCommand, 'application', 'application [SUBCOMMAND]', 'Run application commands'
    # register Cnfs::Commands::InfraCommand, 'infra', 'infra [SUBCOMMAND]', 'Run infrastructure commands'
    register AppController, 'application', 'application [SUBCOMMAND]', 'Run application commands'
    register InfraController, 'infra', 'infra [SUBCOMMAND]', 'Run infrastructure commands'
  end
end
