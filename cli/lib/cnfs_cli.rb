# frozen_string_literal: true

require_relative 'cnfs_cli/version'
require_relative 'cnfs'

module CnfsCli
  extend LittlePlugger
  extend CnfsPlugger
  module Plugins; end

  class << self
    attr_accessor :repository

    def run!(path = Dir.pwd, load_nodes = true)
      # Initialize plugins in the *Cnfs* namespace
      Cnfs.initialize_plugins_from_path(gem_root) if Cnfs.initialize_plugins.empty?
      Cnfs.plugin_root = self
      if Cnfs.path_outside_project?(path)
        raise Cnfs::Error, "Invalid command '#{ARGV.join(' ')}'" unless valid_top_level_command?

        Cnfs.project_root = Pathname.new(path)
        # Cnfs.project_root = '.'
      end

      Cnfs.require_deps(:all)
      # Initialize plugins in the *CnfsCli* namespace
      Cnfs.config.dig(:cli, :dev) ? initialize_development : initialize_plugins
      Cnfs.loader.autoload_all(gem_root)
      # add_repository_autoload_paths

      Cnfs.config.order ||= 'target'
      binding.pry
      Cnfs.config.order = Cnfs.config.order.split(',').map(&:strip).map(&:singularize).unshift('project')
      Cnfs.config.orders = Cnfs.config.order.map(&:pluralize)
      Cnfs.config.asset_names = %w[builders context providers resources repositories runtimes services users]

      Cnfs::Boot.run! do
        Dir.chdir(Cnfs.project_root) do
          Node.create(path: 'project.yml', asset_class: Project) if load_nodes
          yield if block_given?
        end
      end
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
