# frozen_string_literal: true

class MainController < Thor
  include Concerns::CommandController

  # Activate common options
  cnfs_class_options :dry_run, :logging

  if CnfsCli.config.project
    register ImagesController, 'image', 'image SUBCOMMAND [options]', 'Manage service images'
    # register NamespacesController, 'namespace', 'namespace SUBCOMMAND [options]',
             # 'Manage namespace infrastructure and services'
    # register PlansController, 'plan', 'plan SUBCOMMAND [options]', 'Manage environment infrastructure plans (k8s clusters, storage, etc)'
    register ProjectsController, 'project', 'project SUBCOMMAND [options]', 'Manage project'
    register RepositoriesController, 'repository', 'repository SUBCOMMAND [options]',
             'Add, create, list and remove project repositories'
    register ResourcesController, 'resource', 'resource [SUBCOMMAND]', 'Manage component resources'
    register ServicesController, 'service', 'service SUBCOMMAND [options]', 'Manage services in the current namespace'
  end

  # Project Management
  unless CnfsCli.config.project
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
    option :plugin,    desc: 'Create a Cnfs plugin',
                       type: :boolean
    option :component, desc: 'Create a Cnfs component',
                       type: :boolean
    def new(name)
      if Dir.exist?(name) && !validate_destroy('Directory already exists. Destroy and recreate?')
        raise Cnfs::Error, set_color('Directory exists. exiting.', :red)
      end

      execute(name: name)
    end
  end

  # Utility
  desc 'version', 'Show cnfs version'
  def version() = Cnfs::VersionController.new([], options).execute

  class << self
    def exit_on_failure?
      true
    end
  end
end
