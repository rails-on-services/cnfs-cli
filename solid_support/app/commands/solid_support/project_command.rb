# frozen_string_literal: true

module SolidSupport
  class ProjectCommand < ApplicationCommand
    # binding.pry
    # register Hendrix::PluginCommand, 'plugin', 'plugin', 'Create a new Hendrix plugin'
    register module_parent::PluginCommand, 'plugin', 'plugin', "Create a new #{module_parent} plugin"

    desc 'new NAME', "Create a new #{module_parent} project"
    long_desc <<-DESC.tr("\n", "\x5")

      The '#{script} new' command creates a new #{module_parent} project with a default
      directory structure and configuration at the path you specify.

      You can specify extra command-line arguments to be used every time
      '#{script} new' runs in the ~/.config/#{script}/#{script}.yml configuration file

      Note that the arguments specified in the #{script}.yml file don't affect the
      defaults values shown above in this help message.

      Example:
      #{script} new ~/Projects/todo

      This generates a skeletal #{module_parent} project in ~/Projects/todo.
    DESC
    option :force,     desc: 'Force creation even if the project directory already exists',
                       aliases: '-f', type: :boolean
    option :config,    desc: 'Create project with a working configuration (instead of commented examples)',
                       aliases: '-c', type: :boolean
    option :guided,    desc: 'Create project with a guided configuration',
                       aliases: '-g', type: :boolean
    def new(path) = check_dir(path) && execute(path: path, type: :application)

    desc 'version', "Show #{module_parent} version"
    option :all,    desc: 'Show version information for all extensions',
                       aliases: '-a', type: :boolean
    def version() = execute(controller: :project)
  end
end
