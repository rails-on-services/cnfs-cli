# frozen_string_literal: true

require 'cnfs/core/version'

require 'active_record'
require 'active_record/fixtures'
require 'active_support/inflector'
require 'active_support/string_inquirer'
require 'config'
# require 'json_schemer'
require 'lockbox'
require 'open-uri'
# require 'open3'
require 'sqlite3'
require 'thor'
require 'xdg'
require 'zeitwerk'

# adds instance method #to_array to Config::Options class
require_relative '../config/options'

# Config.setup do |config|
#   config.use_env = true
#   config.env_prefix = 'CNFS'
#   config.env_separator = '__'
#   config.merge_nil_values = false
# end


module Cnfs
  # class << self
  #   attr_accessor :platform, :settings

  #   def platform; @platform ||= Cnfs::Core::Platform.new end
  #   def settings; @settings ||= {} end
  # end

  module Core
    class Error < StandardError; end

    class << self
      attr_accessor :plugins, :autoload_dirs, :obj

      def obj; @obj ||= {} end

      def fixture_content(type, file)
        ERB.new(IO.read(fixture(type, file))).result.gsub("---\n", '') if File.exist?(fixture(type, file))
      end

      def fixture(type, file)
        replace_path = type.to_sym.eql?(:project) ? project_config_dir : xdg.config_home.join('cnfs')
        file.gsub(config_dir.to_s, replace_path.to_s)
      end

      def config_dir; gem_root.join('config') end

      def project_config_dir; root.join('cnfs_config') end

      def xdg; @xdg ||= XDG::Environment.new end

      # TODO: rather than Dir.pwd should take from the Platform method that calculates project dir
      def root; Pathname.new(Dir.pwd) end

      def cnfs_project?; Dir.exist?(project_config_dir) end

      def cnfs_services_project?; File.exist?(root.join('lib/core/lib/ros/core.rb')) end

      def gem_root; Pathname.new(File.expand_path('../../..', __FILE__)) end

      def encrypt(value); box.encrypt(value).to_yaml.gsub("--- !binary |-\n  ", '').chomp end

      def decrypt(value)
        box.decrypt(YAML.load("--- !binary |-\n  #{value}\n"))
      rescue Lockbox::DecryptionError
        nil
      end

      def box; @box ||= Lockbox.new(key: ENV['CNFS_MASTER_KEY']) end

      def load_plugin(plugin_name)
        lib_path = File.expand_path("../../../#{plugin_name}/lib", __dir__)
        $:.unshift(lib_path) if !$:.include?(lib_path)
        plugin_module = plugin_name.gsub('-', '/')
        require plugin_module
        plugin_class = plugin_module.camelize.constantize
        self.autoload_dirs += plugin_class.send(:autoload_dirs) if plugin_class.respond_to?(:autoload_dirs)
      end

      def plugin_after_initialize(plugin_name)
        plugin_class = plugin_name.gsub('-', '/').camelize.constantize
        plugin_class.send(:after_initialize) if plugin_class.respond_to?(:after_initialize)
      end

      def loader; @loader ||= Zeitwerk::Loader.new end

      # use Zeitwerk loader for class reloading
      def setup
        plugins.each { |plugin| load_plugin(plugin) }
        # Zeitwerk::Loader.default_logger = method(:puts)
        autoload_dirs.each { |dir| loader.push_dir(dir) }

        loader.enable_reloading
        loader.setup
        plugins.each { |plugin| plugin_after_initialize(plugin) }
        Cnfs::Core::Schema.setup
      end

      def reload
        Cnfs::Core::Schema.reload
        loader.reload
      end

      # TODO: remove lib; only load app dirs; core/schema.rb should still be reloaded
      def autoload_dirs; @autoload_dirs ||= ["#{gem_root}/lib", "#{gem_root}/app/models", "#{gem_root}/app/generators"] end

      def add_plugins(list); self.plugins += list end

      def plugins; @plugins ||= [] end
    end
  end
end
