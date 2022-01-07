# frozen_string_literal: true

module Cnfs
  module New
    class CommandController < Thor
      include Cnfs::Concerns::NewController

      register Cnfs::New::PluginController, 'plugin', 'plugin', 'Create a new CNFS plugin'

      desc 'new NAME', 'Create a new CNFS project'
      long_desc <<-DESC.gsub("\n", "\x5")

      The 'cnfs new' command creates a new CNFS project with a default
      directory structure and configuration at the path you specify.

      You can specify extra command-line arguments to be used every time
      'cnfs new' runs in the ~/.config/cnfs/cnfs.yml configuration file

      Note that the arguments specified in the cnfs.yml file don't affect the
      defaults values shown above in this help message.

      Example:
      cnfs new ~/Projects/todo

      This generates a skeletal CNFS project in ~/Projects/todo.
      DESC
      option :force,     desc: 'Force creation even if the project directory already exists',
        aliases: '-f', type: :boolean
      option :config,    desc: 'Create project with a working configuration (instead of commented examples)',
        aliases: '-c', type: :boolean
      option :guided,    desc: 'Create project with a guided configuration',
        aliases: '-g', type: :boolean
      def new(path) = check_dir(path) && execute(path: path, type: :project)
      # def new(path)
      #   check_dir(path)
      #   binding.pry
      #   execute(path: path, type: :project)
      # end

      # Utility
      desc 'version', 'Show cnfs version'
      def version
        require 'cnfs/version'
        puts("Cnfs #{Cnfs::VERSION}")
      end

      # TODO: Move to MainController that is inherited by Cnfs::Core::MainController
      # def version() = Cnfs::VersionController.new([], options).execute
    end
  end
end
