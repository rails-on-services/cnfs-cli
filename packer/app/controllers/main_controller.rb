# frozen_string_literal: true

class MainController < Thor
  include CommandHelper

  register ProjectsController, 'project', 'project SUBCOMMAND [options]', 'Manage project'

  # Project Management
  if Cnfs.project_root.eql?('.')
    desc 'new NAME', 'Create a new CNFS project'
    long_desc <<-DESC.gsub("\n", "\x5")

      The 'cnfs-packer new' command creates a new CNFS packer project with a default
      directory structure and configuration at the path you specify.

      You can specify extra command-line arguments to be used every time
      'cnfs new' runs in the ~/.config/cnfs-packer/cnfs.yml configuration file

      Note that the arguments specified in the cnfs.yml file don't affect the
      defaults values shown above in this help message.

      Example:
      cnfs new ~/Projects/todo

      This generates a skeletal CNFS packer project in ~/Projects/todo.
    DESC
    option :force,  desc: 'Force creation even if the project directory already exists',
                    aliases: '-f', type: :boolean
    option :config, desc: 'Create project with a working configuration (instead of commented examples)',
                    aliases: '-c', type: :boolean
    option :guided, desc: 'Create project with a guided configuration',
                    aliases: '-g', type: :boolean
    def new(name)
      if Dir.exist?(name) && !validate_destroy('Directory already exists. Destroy and recreate?')
        raise Cnfs::Error, set_color('Directory exists. exiting.', :red)
      end

      FileUtils.rm_rf(name) if Dir.exist?(name)
      execute(name: name)
      # Dir.chdir(name) do
      #   puts Dir.pwd
      #   # Cnfs.reset
      #   # initialize_project
      #   # execute({ blueprints: cmd(:blueprints) }, :new, 2, :configure)
      # end
    end
  end

  unless Cnfs.project_root.eql?('.')
    cnfs_class_options :dry_run, :logging

    desc 'build NAME', 'Build a packer config for a build'
    before :initialize_project
    def build(name)
      execute(name: name)
      # BuildGenerator.new(args, options).invoke_all
    end
  end

  # Utility
  desc 'version', 'Show cnfs version'
  def version
    Main::VersionController.new([], options).execute
  end

  class << self
    def exit_on_failure?
      true
    end
  end
end
