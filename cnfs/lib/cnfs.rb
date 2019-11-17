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

    def autoload_dirs; @autoload_dirs ||= ["#{gem_root}/lib"] end
  end

  module Cli
    class << self
      def config_file; 'config/cnfs.yml' end

      def settings; @settings ||= Config.load_and_set_settings(config_file) end

      def plugins; @plugins ||= (%w[cnfs-core cnfs] + (settings.plugins || [])) end

      def cnfs_project?; File.exist?(config_file) end

      # require any plugins listed in config/cnfs.yml and add each gem's lib path to Zeitwerk
      # NOTE: this currently only works with gems laid out in the same top level dir
      # TODO: get this to work with a real gem based plugin structure
      def setup
        return unless cnfs_project?
        plugins.each do |plugin|
          lib_path = File.expand_path("../../#{plugin}/lib", __dir__)
          $:.unshift(lib_path) if !$:.include?(lib_path)
          plugin_module = plugin.gsub('-', '/')
          require plugin_module
          plugin_class = plugin_module.camelize.constantize
          if not plugin.eql?('cnfs-core') and plugin_class.respond_to?(:autoload_dirs)
            Cnfs::Core.autoload_dirs += plugin_class.send(:autoload_dirs)
          end
        end
        Cnfs::Core.setup
      end
    end
  end
end
