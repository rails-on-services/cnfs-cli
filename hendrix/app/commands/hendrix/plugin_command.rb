# frozen_string_literal: true

module Hendrix
  class PluginCommand < ApplicationCommand
    desc 'new NAME', 'Create a new Hendrix plugin'
    long_desc <<-DESC.gsub("\n", "\x5")

      The 'hendrix plugin new' command creates a new Hendrix project with a default
      directory structure and configuration at the path you specify.

      Example:
      hendrix new ~/Projects/todo

      This generates a skeletal Hendrix plugin in ~/Projects/todo.
    DESC
    option :force,     desc: 'Force creation even if the project directory already exists',
      aliases: '-f', type: :boolean
    option :config,    desc: 'Create project with a working configuration (instead of commented examples)',
      aliases: '-c', type: :boolean
    option :full,    desc: 'Create the full',
      type: :boolean
    def new(path)
      # By default generate an extension which is just a segments directory
      # When passing the full option then create a gem
      type = options.full ? :plugin : :extension
      check_dir(path) && execute(path: path, type: type)
    end
  end
end
