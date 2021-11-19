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
      config.load_nodes = false if config.load_nodes && !config.project
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

      # TODO: If path is different than existing path then reset the configuration; Primarily for specs
      # Load classes, create database, etc
      Cnfs.setup(data_store: config.load_nodes, model_names: model_names)
    end

    def load_root_node
      Node.with_asset_callbacks_disabled do
        Node::Component.create(path: config.root.join('project.yml'), owner_class: Project)
      end
      return unless Project.first

      model_names.each do |model|
        klass = model.classify.constantize
        klass.after_node_load if klass.respond_to?(:after_node_load)
      end
    rescue ActiveRecord::SubclassNotFound => e
      Cnfs.logger.warn('CnfsCli:', e.message.split('.').first.to_s)
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
    def model_names
      (asset_names + component_names + support_names).map(&:singularize)
    end

    def asset_names
      # TODO: assets blueprints environments registries
      # TODO: Fix: Raises an error if this is memoized
      # @asset_names ||= (%w[dependencies images providers resources services users] + operator_names).sort
      (%w[dependencies blueprints images providers resources registries services users] + operator_names).sort
    end

    def operator_names
      # TODO: builders configurators
      %w[provisioners repositories runtimes]
    end

    def component_names
      %w[component project]
    end

    def support_names
      %w[context context_component node runtime_service provisioner_resource]
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
  end
end
