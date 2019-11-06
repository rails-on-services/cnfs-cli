# frozen_string_literal: true

require 'pry'
require 'thor'
require 'config'
require 'active_support/inflector'
require 'active_support/string_inquirer'

module Cnfs
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
      require_relative 'version'
      puts "v#{Cnfs::VERSION}"
    end

    desc 'console', 'Start a command console (short-cut alias: "c")'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    def console(*)
      if options[:help]
        invoke :help, ['console']
      else
        require_relative 'commands/console'
        Cnfs::Commands::Console.new(options).execute
      end
    end

    # Load sub-commnds
    require_relative 'commands/application'
    register Cnfs::Commands::ApplicationC, 'application', 'application [SUBCOMMAND]', 'Run application commands (short-cut alias: "a")'

    require_relative 'commands/infra'
    register Cnfs::Commands::InfraC, 'infra', 'infra [SUBCOMMAND]', 'Run infrastructure commands (short-cut alias: "i")'
  end

  module Cli
    class << self
      def config_file; 'config/cnfs.yml' end

      def settings; @settings ||= Config.load_and_set_settings(config_file) end

      def plugins; @plugins ||= (%w[cnfs-core] + (settings.plugins || [])) end

      def cnfs_project?; File.exist?(config_file) end

      # require any plugins listed in config/cnfs.yml and add each gem's lib path to Zeitwerk
      # NOTE: this currently only works with gems laid out in the same top level dir
      # TODO: get this to work with a real gem based plugin structure
      def setup
        return unless cnfs_project?
        plugins.each do |plugin|
          lib_path = File.expand_path("../../../#{plugin}/lib", __dir__)
          $:.unshift(lib_path) if !$:.include?(lib_path)
          plugin_module = plugin.gsub('-', '/')
          require plugin_module
          plugin_class = plugin_module.camelize.constantize
          if not plugin.eql?('cnfs-core') and plugin_class.respond_to?(:autoload_dirs)
            Cnfs::Core.autoload_dirs += plugin_class.send(:autoload_dirs)
          end
        end
        Cnfs::Core.setup
      end
    end
  end
end
