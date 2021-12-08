# frozen_string_literal: true

require_relative 'cnfs_cli/version'
require_relative 'cnfs'

require 'pry'

module CnfsCli
  extend LittlePlugger
  extend CnfsPlugger
  module Plugins; end

  class << self
    attr_reader :config, :load_nodes

    # Track Repository Components
    # Used by Components to reference a component from within a Repository
    def register_component(name:, path:)
      components[name] ||= path
      add_loader(name: name, path: path.join('app'))
    end

    def components
      @components ||= {}
    end

    # Track loaded 'app' paths including those from Repository Components and Project but not core framework
    # Used by ApplicationGenerator to compile template directories
    def add_loader(name:, path:)
      return unless path.exist?

      Cnfs.add_loader(name: name, path: path).setup
      Cnfs.add_module(name: name, path: path)

      loaders[name] ||= path
    end

    def loaders
      @loaders ||= {}
    end

    # def mods
    #   @mods ||= {}
    # end

    # docs for run!
    def run!(path: Dir.pwd, load_nodes: true)
      # Initialize plugins in the *Cnfs* namespace
      Cnfs.initialize_plugins_from_path(gem_root) if Cnfs.initialize_plugins.empty?
      t_hash = Cnfs::Timer.append(title: 'Application run time', start: Time.now).last

      require_relative 'cnfs_cli/config'
      config(path: path, load_nodes: load_nodes)

      Dir.chdir(config.root) do
        require_project_config_files
        setup
        register_repository_components

        # next line needs deps to be loaded to use AS.singularize
        load_root_node if config.load_nodes # && options.no_cache
        yield if block_given?
      end
      t_hash[:end] = Time.now
    end

    # When called for the first time the path can be overridden
    # All subsequent calls will return the value set on the first call
    def config(**options) = @config ||= CnfsCli::Config.new(**options)

    # Yield the configuration object for project configuration in config/application.rb
    def configuration() = yield(config)

    def require_project_config_files
      require_relative application_path if application_path.exist?
      config.after_user_config
      initializers_path.glob('**/*.rb').each { |file| require file } if initializers_path.exist?
      Cnfs.config = config
    end

    def application_path() = config_path.join('application.rb')

    def initializers_path() = config_path.join('initializers')

    # config_path is the one path that cannot be set by the user
    # config_path is always <project_root_path>/config
    def config_path() = config.root.join('config')

    # Process the configuration
    def setup
      default_commands = config.project ? %w[project console] : %w[help new]
      ARGV.append(*default_commands) if ARGV.size.zero?

      # Require all dependencies
      deps = config.project ? :all : :minimal
      Cnfs.require_deps(deps)
      # TODO: Refector to move to the appropriate gem using AS Notifications
      ActiveSupport::Inflector.inflections do |inflect|
        # inflect.uncountable %w[aws cnfs dns kubernetes postgres rails redis]
      end

      # Initialize plugins in the *CnfsCli* namespace
      Cnfs.plugin_root = self
      Cnfs.config.dev ? initialize_development : initialize_plugins

      # TODO: If path is different than existing path then reset the configuration; Primarily for specs
      # Load classes, create database, etc
      Cnfs.setup(data_store: config.load_nodes, model_names: model_names)
    end

    def load_root_node
      Cnfs.with_timer('load nodes') do
        Node.with_asset_callbacks_disabled do
          Node::Component.create(path: config.root.join('project.yml'), owner_class: Project)
        end
      end
      return unless Project.first

      # TODO: Is this still a thing?
      model_names.each do |model|
        klass = model.classify.constantize
        klass.after_node_load if klass.respond_to?(:after_node_load)
      end
    rescue ActiveRecord::SubclassNotFound => e
      binding.pry
      Cnfs.logger.fatal('CnfsCli:', e.message.split('.').first.to_s)
      raise Cnfs::Error, ''
    end

    # Initialize plugins in the *CnfsCli* namespace
    def initialize_development
      require 'pry'
      initialize_plugins_from_path(gem_root, Cnfs.logger)
    end

    # Return the root of the gem
    def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

    # The model class list for which tables will be created in the database
    def model_names() = (asset_names + component_names + support_names).map(&:singularize).sort

    def asset_names
      # TODO: assets blueprints environments registries
      # TODO: Fix: Raises an error if this is memoized
      # @asset_names ||= (%w[dependencies images providers resources services users] + operator_names).sort
      (%w[dependencies blueprints images plans providers resources registries services users] + operator_names).sort
    end

    def operator_names() = %w[builders configurators provisioners repositories runtimes]

    def component_names() = %w[component project]

    def support_names() = %w[context context_component node runtime_service provisioner_resource]

    def platform() = @platform ||= Platform.new

    # TODO: this needs to be refactored
    def reload(path: nil, load_nodes: true)
      @config = nil
      # load_component(path: path, load_nodes: load_nodes)
      # Cnfs.project_root = nil
      # binding.pry
      # Cnfs.translations = nil
      # Cnfs.context = nil
      # Cnfs.reset
      # Dir.chdir(path) { puts Cnfs.context; puts Cnfs.project_root } if path
      # set_config_options
      Cnfs.loader.reload
      Cnfs.data_store.reload
    end

    def register_repository_components
      return unless CnfsCli.config.paths.src.exist?

      CnfsCli.config.paths.src.children.select(&:directory?).each do |repo_path|
        repo = Repository.new(name: repo_path.basename.to_s)
        repo.register_components
      end
    end
  end
end
