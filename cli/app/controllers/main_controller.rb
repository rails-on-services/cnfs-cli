# frozen_string_literal: true

class MainController < Thor
  include CommandHelper

  # Activate common options
  cnfs_class_options :dry_run, :logging

  unless Cnfs.project_root.eql?('.')
    register ProjectsController, 'project', 'project SUBCOMMAND [options]', 'Manage project'
    register RepositoriesController, 'repository', 'repository SUBCOMMAND [options]', 'Add, create, list and remove project repositories'
    register EnvironmentsController, 'environment', 'environment SUBCOMMAND [options]', 'Manage environment infrastructure and services. (k8s clusters, storage, etc)'
    register BlueprintsController, 'blueprint', 'blueprint SUBCOMMAND [options]', 'Manage environment infrastructure blueprints (k8s clusters, storage, etc)'
    register InfraController, 'infra', 'infra [SUBCOMMAND]', 'Manage environment infrastructure. (short-cut: i)'
    register NamespacesController, 'namespace', 'namespace SUBCOMMAND [options]', 'Manage namespace infrastructure and services'
    register ImagesController, 'image', 'image SUBCOMMAND [options]', 'Manage service images'
    register ServicesController, 'service', 'service SUBCOMMAND [options]', 'Manage services in the current namespace'
  end

  def self.exit_on_failure?
    true
  end

  # This command will not show up in a list; the user has to know it exists and call it directly
  if Cnfs.config.dig(:cli, :dev) && ARGV[0].eql?('dev')
    cnfs_options :environment, :namespace
    desc 'dev', 'Placeholder command for development of new commands'
    def dev
      binding.pry
      # run(:dev)
    end
  end

  # Project Management
  if Cnfs.project_root.eql?('.')
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
    option :force,  desc: 'Force creation even if the project directory already exists',
                    aliases: '-f', type: :boolean
    option :config, desc: 'Create project with a working configuration (instead of commented examples)',
                    aliases: '-c', type: :boolean
    def new(name)
      if Dir.exist?(name) and not validate_destroy('Directory already exists. Destroy and recreate?')
        raise Cnfs::Error, set_color('Directory exists. exiting.', :red)
      end
      execute(name: name)
    end
  end

  # Utility
  desc 'version', 'Show cnfs version'
  def version
    Main::VersionController.new([], options).execute
  end
end
