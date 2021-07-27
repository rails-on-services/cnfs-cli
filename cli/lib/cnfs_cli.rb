# frozen_string_literal: true

require_relative 'cnfs_cli/version'
require_relative 'cnfs'

module CnfsCli
  extend LittlePlugger
  extend CnfsPlugger
  module Plugins; end

  class << self
    attr_accessor :repository

    def initialize!
      # Initialize plugins in the Cnfs namespace
      Cnfs.initialize_dev_plugins(gem_root) if Cnfs.initialize_plugins.empty?
      Cnfs.project_file = 'config/project.yml'
      Cnfs.plugin_root = self
      Cnfs.initialize! do |event|
        if event.eql?(:before_loader)
          # Initialize plugins in the CnfsCli namespace
          Cnfs.config.dig(:cli, :dev) ? initialize_development : initialize_plugins
          Cnfs.autoload_dirs.concat(Cnfs.autoload_all(gem_root))
        elsif event.eql?(:after_loader)
          ActiveSupport::Notifications.subscribe('before_project_configuration.cnfs') do |_event|
            Cnfs::Configuration.models = models_to_parse
          end
          yield if block_given?
        end
      end
    end

    def models_to_parse
      [Blueprint, Builder, Dependency, Environment, Location, Namespace, Project,
       Provider, Registry, Repository, Resource, Runtime, Service, User]
    end

    def initialize_development
      require 'pry'
      initialize_dev_plugins(gem_root)
    end

    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
    end
  end
end
