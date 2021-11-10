# frozen_string_literal: true

require_relative 'cnfs_cli/version'
require_relative 'cnfs'

require 'pry'

module CnfsCli
  extend LittlePlugger
  extend CnfsPlugger
  module Plugins; end

  class << self
    attr_reader :configuration, :config

    # docs for run!
    def run!(path: Dir.pwd, load_nodes: true)
      # Initialize plugins in the *Cnfs* namespace
      Cnfs.initialize_plugins_from_path(gem_root) if Cnfs.initialize_plugins.empty?

      load_configurations(path: path, load_nodes: load_nodes)

      Dir.chdir(config.root) do
        setup
        # next line needs deps to be loaded to use AS.singularize
        # configuration.set_config_options
        load_root_node if config.load_nodes
        yield if block_given?
      end
    end

    # Setup CnfsCli.config (project settings) and Cnfs.config (core tool settings)
    def load_configurations(path:, load_nodes:)
      require_relative 'cnfs_cli/config'
      @configuration = CnfsCli::Config.new(file_name: 'cnfs-cli.yml', cwd: path, load_nodes: load_nodes)
      @config = @configuration.config
      Cnfs.configuration = Cnfs::Config.new(name: 'cnfs-cli', file_name: 'cnfs-cli.yml', cwd: path)
      Cnfs.config = Cnfs.configuration.config
      config.load_nodes = false if config.load_nodes and not config.project
    end

    # Proces the configuration
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
      Cnfs.plugin_root = self # used only by Cnfs::Boot; See if can remove this
      Cnfs.config.dev ? initialize_development : initialize_plugins

      # Tell the loader to load this gem's classes
      Cnfs.loader.autoload(paths: [gem_root])
      # add_repository_autoload_paths

      # TODO: If path is different than existing path then reset the configuration; Primarily for specs
      # Load classes, create database, etc
      Cnfs.setup(data_store: config.load_nodes, schema_model_names: schema_model_names)
    end

    def load_root_node
      _n = Node::Component.create(path: config.root.join('project.yml'), owner_class: Project)
      return unless Project.first

      schema_model_names.each do |model|
        klass = model.classify.constantize
        klass.after_node_load if klass.respond_to?(:after_node_load)
      end
    rescue ActiveRecord::SubclassNotFound => err
      Cnfs.logger.warn("#{err.message.split('.').first}")
      raise Cnfs::Error, ''
    end

    # Initialize plugins in the *CnfsCli* namespace
    def initialize_development
      require 'pry'
      initialize_plugins_from_path(gem_root, Cnfs.logger)
    end

    # Return the root of the gem
    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
    end

    # The model class list for which tables will be created in the database
    def schema_model_names
      %w[blueprint context context_component component dependency environment image node
        project provider provisioner repository resource runtime service user]
    end

    def asset_names
      %w[environments providers provisioners resources repositories runtimes services users]
    end

    # TODO: this needs to be refactored
    def reload(path: nil, load_nodes: true)
      load_configurations(path: path, load_nodes: load_nodes)
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


    # Scan repositories for subdirs in <repository_root>/cnfs/app and add them to autoload_dirs
    # TODO: plugin and repository load paths should work the same way and follow same class structures
    # So there should just be one method to populate autoload_dirs
    # TODO: This needs to be refactored b/c repositories are not in the Cnfs.repositories array now
    def add_repository_autoload_paths
      binding.pry
      Cnfs.repositories.each do |_name, config|
        cnfs_load_path = Cnfs.project_root.join(config.path, 'cnfs/app')
        next unless cnfs_load_path.exist?

        paths_to_load = cnfs_load_path.children.select(&:directory?)
        Cnfs.autoload_dirs.concat(paths_to_load)
      end
    end
  end
end
