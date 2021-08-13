# frozen_string_literal: true

require_relative 'cnfs_cli/version'
require_relative 'cnfs'

module CnfsCli
  extend LittlePlugger
  extend CnfsPlugger
  module Plugins; end

  class << self
    attr_accessor :repository

    def run!
      # Initialize plugins in the Cnfs namespace
      Cnfs.initialize_dev_plugins(gem_root) if Cnfs.initialize_plugins.empty?
      Cnfs.project_file = 'config/project.yml'
      Cnfs.plugin_root = self
      Cnfs::Boot.initialize! do # |event|
        # if event.eql?(:before_loader)
          # Initialize plugins in the CnfsCli namespace
          Cnfs.config.dig(:cli, :dev) ? initialize_development : initialize_plugins
          Cnfs.autoload_dirs.concat(Cnfs.autoload_all(gem_root))
          # ActiveSupport::Notifications.subscribe('before_loader_push_dirs.cnfs') do |_event|
          #   binding.pry
          #   add_repository_autoload_paths
          # end
        end
        # elsif event.eql?(:after_loader)
        Cnfs::Boot.run! do # |event|
          ActiveSupport::Notifications.subscribe('before_project_configuration.cnfs') do |_event|
            Cnfs::Configuration.models = models_to_parse
          end
          yield if block_given?
        # end
      end
    end

    def models_to_parse
      # [Blueprint, Builder, Dependency, Environment, Location, Namespace, Project,
      #  Provider, Registry, Repository, Resource, Runtime, Service, User]
      [Blueprint, Builder, Dependency, Environment, Stack, Namespace, Project,
       Provider, Repository, Image, Resource, Runtime, Service, User]
    end

    def initialize_development
      require 'pry'
      initialize_dev_plugins(gem_root)
    end

    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
    end

    # Scan repositories for subdirs in <repository_root>/cnfs/app and add them to autoload_dirs
    # TODO: plugin and repository load paths should work the same way and follow same class structures
    # So there should just be one method to populate autoload_dirs
    # TODO: This needs to be refactored b/c repositories are not in the Cnfs.repositories array now
    def add_repository_autoload_paths
      Cnfs.repositories.each do |_name, config|
        cnfs_load_path = Cnfs.project_root.join(config.path, 'cnfs/app')
        next unless cnfs_load_path.exist?

        paths_to_load = cnfs_load_path.children.select(&:directory?)
        Cnfs.autoload_dirs.concat(paths_to_load)
      end
    end
  end
end
