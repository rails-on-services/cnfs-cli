# frozen_string_literal: true

class PrimaryController < CommandsController
  OPTS = []
  OPTS.append(:debug) if Cnfs.config.dig(:cli, :dev)

  Cnfs.controllers.each do |controller|
    controller = OpenStruct.new(controller)
    register controller.klass.safe_constantize, controller.title, controller.help, controller.description
  end

  register ComponentController, 'add', 'add COMPONENT [options]', 'Add a project component'
  register Component::RemoveController, 'remove', 'remove COMPONENT NAME', 'Remove a project component'
  # NOTE: This is like Amplify status
  register Primary::ListController, 'list', 'list COMPONENT', 'List project components'

  register ProjectController, 'project', 'project SUBCOMMAND [options]', 'Manage project'
  register EnvironmentsController, 'environment', 'environment SUBCOMMAND [options]', 'Manage environment infrastructure and services. (k8s clusters, storage, etc)'
  register NamespacesController, 'namespace', 'namespace SUBCOMMAND [options]', 'Manage namespace infrastructure and services'
  register ImagesController, 'image', 'image SUBCOMMAND [options]', 'Manage service images'
  register ServicesController, 'service', 'service SUBCOMMAND [options]', 'Manage services in the current namespace'

  def self.exit_on_failure?
    true
  end

  # if Cnfs.config.dig(:cli, :dev)
  #   OPTS.unshift(:env, :ns, :fail_fast)
  #   OPTS.append(:noop, :quiet, :verbose)
  #   desc 'dev', 'Placeholder command for development of new commands'
  #   def dev
  #     run(:dev)
  #   end
  # end

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
    option :force, desc: 'Force creation even if the project directory already exists',
      aliases: '-f', type: :boolean
    def new(name)
      if Dir.exist?(name)
        if options.force || yes?('Directory already exists. Destroy and recreate?')
          FileUtils.rm_rf(name)
        else
          raise Cnfs::Error, set_color('Directory exists. exiting.', :red)
        end
      end
      NewController.new(name, options).execute
    end
  end

  # Utility
  desc 'version', 'Show cnfs version'
  def version
    puts "v#{Cnfs::VERSION}"
  end
  include Cnfs::Options
end
