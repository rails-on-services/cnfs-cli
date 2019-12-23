# frozen_string_literal: true

require 'cnfs/core/version'

require 'active_record'
require 'active_record/fixtures'
require 'active_support/inflector'
require 'active_support/string_inquirer'
require 'config'
require 'json_schemer'
require 'lockbox'
# require 'open3'
require 'sqlite3'
require 'thor'
require 'zeitwerk'

# adds instance method #to_env to Config::Options class
require_relative '../config/options'

# Config.setup do |config|
#   config.use_env = true
#   config.env_prefix = 'CNFS'
#   config.env_separator = '__'
#   config.merge_nil_values = false
# end
# require 'yaml_vault'


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

      def project_fixture_content(file)
        ERB.new(IO.read(project_fixture(file))).result.gsub("---\n", '') if File.exist?(project_fixture(file))
      end

      def project_fixture(file)
        file.gsub(config_dir.to_s, project_config_dir.to_s)
      end

      def config_dir; gem_root.join('config') end

      # def project_config_dir; Pathname.new(File.expand_path('cnfs_config', Dir.pwd)) end
      def project_config_dir; root.join('cnfs_config') end

      # TODO: rather than Dir.pwd should take from the Platform method that calculates project dir
      def root; Pathname.new(Dir.pwd) end

      def cnfs_project?; Dir.exist?(project_config_dir) end
      # def config_dirs
      #   [gem_root.join('config'), Pathname.new(File.expand_path('cnfs_config', Dir.pwd))].uniq
      # end

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
        # Set up in-memory database
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        Cnfs::Core::Schema.create_schema
      end

      def reload
        # Enable fixtures to be re-seeded on code reload
        ActiveRecord::FixtureSet.reset_cache
        Cnfs::Core::Schema.create_schema
        loader.reload
      end

      # TODO: remove lib; only load app dirs; core/schema.rb should still be reloaded
      def autoload_dirs; @autoload_dirs ||= ["#{gem_root}/lib", "#{gem_root}/app/models", "#{gem_root}/app/generators"] end

      def add_plugins(list); self.plugins += list end

      def plugins; @plugins ||= [] end
    end
  end
end
