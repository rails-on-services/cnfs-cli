# frozen_string_literal: true

module Cnfs
  class Cli < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    # Global commands
    desc 'version', 'cnfs version'
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
    register PrimaryController, 'deployment', 'deployment [SUBCOMMAND]', 'Run deployment commands'
    register InfraController, 'infra', 'infra [SUBCOMMAND]', 'Run infrastructure commands'
  end
end