# frozen_string_literal: true

class ProjectsController < Thor
  include CommandHelper

  # Activate common options
  cnfs_class_options :dry_run, :logging

  # register Projects::SetController, 'set', 'set [SUBCOMMAND]', 'Set a project configuration value'
  # register Projects::AddController, 'add', 'add [SUBCOMMAND] [options]', 'Add a package to the project'

  # desc 'config', 'Display project configuration'
  # option :local, desc: 'Display local overrides',
  #                aliases: '-l', type: :boolean
  # def config
  #   # puts Cnfs.app.attributes
  #   # puts "-----"
  #   YAML.load_file('cnfs.yml').each do |key, value|
  #     puts "#{key}: #{value}"
  #   end
  # end

  desc 'console', 'Start a CNFS project console (short-cut: c)'
  # TODO: Maybe have an option that removes :enfironment and namespace from options before running command
  # So that Cnfs.app.valid? returns true if env and ns are not necessary
  # cnfs_options :environment, :namespace, :tags, :repository
  before :initialize_project
  # before :ensure_valid_project
  map %w[c] => :console
  def console
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

  # desc 'customize', 'Customize project templates'
  # def customize
  #   Cnfs.invoke_plugins_with(:customize)
  # end
end
