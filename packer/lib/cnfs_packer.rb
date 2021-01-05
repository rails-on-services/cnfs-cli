# frozen_string_literal: true

require 'bump'
require 'net/http'
# require 'packer-config'
require 'uri'

require_relative 'cnfs_packer/version'
require_relative 'cnfs'
require 'pry'

# Documentation
module CnfsPacker
  class Error < StandardError; end

  extend LittlePlugger
  extend CnfsPlugger

  # Required by LittlePlugger
  module Plugins; end

  class << self
    attr_accessor :__build

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize!
      Cnfs.initialize_dev_plugins(gem_root) if Cnfs.initialize_plugins.empty?
      Cnfs.project_file = 'config/project.yml'
      Cnfs.plugin_root = self
      Cnfs.initialize! do |event|
        case event
        when :before_loader
          Cnfs.require_deps
          Cnfs.config.dig(:cli, :dev) ? initialize_development : initialize_plugins
          Cnfs.autoload_dirs.concat(Cnfs.autoload_all(gem_root))
        when :after_loader
          yield if block_given?
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def plugin_lib
      self
    end

    def before_project_configuration
      # binding.pry
      Cnfs::Configuration.models = models_to_parse
    end

    def models_to_parse
      # Dir.chdir(gem_root.join('app/models')) do
      #   # Dir['*.rb'].map { |file| file.delete_suffix('.rb').classify.safe_constantize }
      #   Dir['*.rb'].map { |file| file.delete_suffix('.rb').classify }.reject { |r| r.eql?('ApplicationRecord') }
      # end
      [Build, Builder, OperatingSystem, PostProcessor, Project, Provisioner]
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
