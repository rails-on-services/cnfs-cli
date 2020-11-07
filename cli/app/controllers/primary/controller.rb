# frozen_string_literal: true

module Primary
  class Controller < CommandsController
    Cnfs.controllers.each do |controller|
      controller = OpenStruct.new(controller)
      register controller.klass.safe_constantize, controller.title, controller.help, controller.description
    end

    register ComponentAddController, 'add', 'add COMPONENT [options]', 'Add a project component'
    register ComponentRemoveController, 'remove', 'remove COMPONENT NAME', 'Remove a project component'

    register ConfigController, 'config', 'config SUBCOMMAND', 'Get and set project configuration values'
    # NOTE: This is like Amplify status
    register ListController, 'list', 'list COMPONENT', 'List configuration components'

    register EnvironmentsController, 'environment', 'environment SUBCOMMAND [options]', 'Manage environment infrastructure and services. (k8s clusters, storage, etc)'
    register NamespacesController, 'namespace', 'namespace SUBCOMMAND [options]', 'Manage namespace infrastructure and services'
    register ServicesController, 'service', 'service SUBCOMMAND [options]', 'Manage services in the current namespace'

    def self.exit_on_failure?
      true
    end

    unless %w[new version].include?(ARGV[0]) or (ARGV[0]&.eql?('help') and %w[new version].include?(ARGV[1]))
      class_option :environment, desc: 'Target environment',
        aliases: '-e', type: :string, required: true, default: Cnfs.config.environment
      class_option :namespace, desc: 'Target namespace',
        aliases: '-n', type: :string, required: true, default: Cnfs.config.namespace
      class_option :fail_fast,  desc: 'Skip any remaining commands after a command fails',
        aliases: '--ff', type: :boolean
    end

    class_option :debug, desc: 'Display deugging information with degree of verbosity',
      aliases: '-d', type: :numeric, default: Cnfs.config.debug
    # class_option :help, desc: 'Display usage information',
    #   aliases: '-h', type: :boolean
    class_option :noop, desc: 'Do not execute commands',
      type: :boolean, default: Cnfs.config.noop
    class_option :quiet, desc: 'Suppress status output',
      aliases: '-q', type: :boolean, default: Cnfs.config.quiet
    # class_option :tag, type: :string
    class_option :verbose, desc: 'Display extra information from command',
      aliases: '-v', type: :boolean, default: Cnfs.config.verbose

    if Cnfs.config.dig(:cli, :dev)
      desc 'dev', 'Placeholder command for development of new commands'
      def dev
        run(:dev)
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

    desc 'init', 'Initialize the project'
    long_desc <<-DESC.gsub("\n", "\x5")

    The 'cnfs init' command initializes a newly cloned CNFS project with the following operations:

    Clone repositories
    Check for dependencies
    DESC
    def init
      run(:init)
    end

    desc 'console', 'Start a CNFS project console (short-cut: c)'
    map %w[c] => :console
    def console
      run(:console)
    end

    # Deployment Manifests
    desc 'generate', 'Generate manifests for application deployment'
    option :clean, desc: 'Delete all existing manifests before generating',
      aliases: '-c', type: :boolean
    def generate
      run(:generate)
    end

    # Utility
    desc 'version', 'Show cnfs version'
    def version
      puts "v#{Cnfs::VERSION}"
    end
  end
end
