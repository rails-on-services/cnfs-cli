# frozen_string_literal: true

require 'pry'
require 'thor'
require 'config'
require 'active_support/inflector'
require 'active_support/string_inquirer'

require 'cnfs/version'

module Cnfs
  class Error < StandardError; end

  class << self
    def gem_root; Pathname.new(File.expand_path('../..', __FILE__)) end

    def autoload_dirs; @autoload_dirs ||= ["#{gem_root}/lib", "#{gem_root}/app/controllers"] end
  end

  module Cli
    class << self
      # TODO: determine how plugins are discovered and loaded
      # 1. does the core gem handle the discovery rather than cli?
      # 2. how are plugins declared?
      # def config_file; 'config/cnfs.yml' end

      # def settings; @settings ||= Config.load_and_set_settings(config_file) end

      # def plugins; @plugins ||= (%w[cnfs-core cnfs cnfs-ext] + (settings.plugins || [])) end
      # def plugins; @plugins ||= %w[cnfs-core cnfs cnfs-ext] end
      # def plugins; @plugins ||= %w[cnfs-core cnfs] end
      # def plugins; @plugins ||= %w[cnfs cnfs-ext] end

      # def cnfs_project?; File.exist?(config_file) end
      # def cnfs_project?; Dir.exist?('cnfs_config') end

      # require any plugins listed in config/cnfs.yml and add each gem's lib path to Zeitwerk
      # NOTE: this currently only works with gems laid out in the same top level dir
      # TODO: get this to work with a real gem based plugin structure
      def setup
        require_core
        if not Cnfs::Core.cnfs_project?
          STDOUT.puts('WARN: not a cnfs project')
          return
        end
        Cnfs::Core.add_plugins(%w[cnfs])
        Cnfs::Core.setup
      end

      def require_core
        plugin = 'cnfs-core'
        lib_path = File.expand_path("../../#{plugin}/lib", __dir__)
        $:.unshift(lib_path) if !$:.include?(lib_path)
        plugin_module = plugin.gsub('-', '/')
        require plugin_module
      end
    end
  end
end
