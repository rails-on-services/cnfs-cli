# frozen_string_literal: true

module Hendrix
  class ProjectCommand < ApplicationCommand
    # binding.pry
    # register Hendrix::PluginCommand, 'plugin', 'plugin', 'Create a new Hendrix plugin'
    register module_parent::PluginCommand, 'plugin', 'plugin', 'Create a new Hendrix plugin'

    desc 'new NAME', 'Create a new Hendrix project'
    long_desc <<-DESC.tr("\n", "\x5")

      The 'hendrix new' command creates a new Hendrix project with a default
      directory structure and configuration at the path you specify.

      You can specify extra command-line arguments to be used every time
      'hendrix new' runs in the ~/.config/hendrix/hendrix.yml configuration file

      Note that the arguments specified in the hendrix.yml file don't affect the
      defaults values shown above in this help message.

      Example:
      hendrix new ~/Projects/todo

      This generates a skeletal Hendrix project in ~/Projects/todo.
    DESC
    option :force,     desc: 'Force creation even if the project directory already exists',
                       aliases: '-f', type: :boolean
    option :config,    desc: 'Create project with a working configuration (instead of commented examples)',
                       aliases: '-c', type: :boolean
    option :guided,    desc: 'Create project with a guided configuration',
                       aliases: '-g', type: :boolean
    def new(path) = check_dir(path) && execute(path: path, type: :application)

    desc 'version', 'Show hendrix version'
    option :all,    desc: 'Show version information for all extensions',
                       aliases: '-a', type: :boolean
    def version() = execute(controller: :project)
  end
end
