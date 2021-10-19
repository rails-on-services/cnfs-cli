# frozen_string_literal: true

require_relative 'cnfs_cli/version'
require_relative 'cnfs'

module CnfsCli
  extend LittlePlugger
  extend CnfsPlugger
  module Plugins; end

  class << self
    attr_accessor :repository

    # docs for run!
    def run!(path: Dir.pwd, load_nodes: true)
      # TODO: If path is different than existing path then reset the configuration; Primarily for specs
      Dir.chdir(path) { setup }

      # If path is not at the root or subdir of a valid project
      if Cnfs.project_root.nil? # Cnfs.path_outside_project? # (path)
        load_nodes = false
        process_cmd 
      else
        set_config_options
      end

      # Load classes, create database, etc
      Cnfs.setup

      Dir.chdir(Cnfs.project_root) do
        _n = Node::Component.create(path: Cnfs.project_file, owner_class: Project) if load_nodes
        load_project_files if Project.first
        yield if block_given?
      end
    end

    def reload(path: nil)
      Cnfs.project_root = nil
      # binding.pry
      Cnfs.translations = nil
      Cnfs.context = nil
      Cnfs.reset
      Dir.chdir(path) { puts Cnfs.context; puts Cnfs.project_root } if path
      set_config_options
      Cnfs.loader.reload
      Cnfs.data_store.reload
    end

    def setup
      # Initialize plugins in the *Cnfs* namespace
      Cnfs.initialize_plugins_from_path(gem_root) if Cnfs.initialize_plugins.empty?

      # Require all dependencies
      Cnfs.require_deps(:all)

      # Initialize plugins in the *CnfsCli* namespace
      Cnfs.plugin_root = self # used only by Cnfs::Boot; See if can remove this
      Cnfs.config.dig(:cli, :dev) ? initialize_development : initialize_plugins

      # Tell the loader to load this gem's classes
      Cnfs.loader.autoload(paths: [gem_root])
      # add_repository_autoload_paths
    end

    def set_config_options
      Cnfs.config.order ||= 'target'
      if Cnfs.config.config.x_components
        Cnfs.config.order = Cnfs.config.config.x_components.map(&:name).map(&:singularize).unshift('project')
        Cnfs.config.orders = Cnfs.config.order.map(&:pluralize)
      end
      # binding.pry
      Cnfs.config.asset_names = Cnfs.asset_names
    end

    def load_project_files
      # Get the component names, but only after the Project.is loaded
      # context = Context.first_or_create(owner: Project.first)
      # TODO: Target.first is not correct
      # context.update(component: Target.first)
      Cnfs.schema_model_names.each do |model|
        klass = model.classify.constantize
        klass.after_node_load if klass.respond_to?(:after_node_load)
      end
      # ActiveSupport::Notifications.instrument('after_models_created.cnfs-cli')
    end

    def process_cmd
      if valid_top_level_command?
        Cnfs.project_root = Pathname.new(Dir.pwd)
      else
        raise Cnfs::Error, "Invalid command '#{ARGV.join(' ')}'"
      end
      false
    end

    def valid_top_level_command?
      # Display help for new command when no arguments are passed
      ARGV.append('help', 'new') if ARGV.size.zero?
      # TODO: Valid commands come from the encolsing app, e.g. cnfs-cli
      %w[dev help new version].each do |valid_command|
        break [valid_command] if valid_command.start_with?(ARGV[0])
      end.size.eql?(1)
    end

    # Initialize plugins in the *CnfsCli* namespace
    def initialize_development
      require 'pry'
      initialize_plugins_from_path(gem_root, Cnfs.logger)
    end

    # REturn the root of the gem
    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
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
