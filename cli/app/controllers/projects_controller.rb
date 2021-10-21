# frozen_string_literal: true

class ProjectsController < Thor
  include CommandHelper

  # Activate common options
  cnfs_class_options :dry_run, :logging
  class_before :initialize_project
  cnfs_class_options Project.first.command_options_list

  register Projects::SetController, 'set', 'set [SUBCOMMAND]', 'Set a project configuration value'
  register Projects::AddController, 'add', 'add [SUBCOMMAND] [options]', 'Add a package to the project'

  desc 'config', 'Display project configuration'
  option :local, desc: 'Display local overrides',
                 aliases: '-l', type: :boolean
  def config
    YAML.load_file(Cnfs.project_file).each do |key, value|
      puts "#{key}: #{value}"
    end
  end

  desc 'console', 'Start a CNFS project console (short-cut: c)'
  # TODO: Maybe have an option that removes :enfironment and namespace from options before running command
  # TODO: Bail right after parsing nodes if there is an issue with the project being valid
  map %w[c] => :console
  def console(*users)
    Context.first.update(args: {users: users})
  # def console
    execute
  end

  desc 'init', 'Initialize the project'
  long_desc <<-DESC.gsub("\n", "\x5")

  The 'cnfs init' command initializes a newly cloned CNFS project with the following operations:

  Clone repositories
  Check for dependencies
  DESC
  def init
    command.new(options: options).execute
  end

  desc 'customize', 'Customize project templates'
  def customize
    Cnfs.invoke_plugins_with(:customize)
  end
end
