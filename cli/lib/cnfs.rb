# frozen_string_literal: true

require 'active_record'
require 'active_record/fixtures'
require 'active_support/inflector'
require 'active_support/string_inquirer'
require 'config'
# require 'json_schemer'
require 'lockbox'
require 'open-uri'
require 'pry'
# require 'open3'
require 'sqlite3'
require 'thor'
require 'xdg'
require 'zeitwerk'

require_relative 'ext/config/options'
require_relative 'ext/string'
require_relative 'cnfs/errors'
require_relative 'cnfs/version'

Config.setup do |config|
  config.use_env = true
  config.env_separator = '__'
  # config.env_prefix = 'CNFS'
  # config.merge_nil_values = false
end

module Cnfs
  class Error < StandardError; end

  class << self
    attr_accessor :plugins, :autoload_dirs, :obj

    def obj; @obj ||= {} end

    def config_content(type, file)
      ERB.new(IO.read(fixture(type, file))).result.gsub("---\n", '') if File.exist?(fixture(type, file))
    end

    def fixture(type, file)
      replace_path = type.to_sym.eql?(:project) ? project_config_dir : xdg.config_home.join('cnfs').join(project_name)
      file.gsub(config_dir.to_s, replace_path.to_s)
    end

    def project_name; File.read(config_file).chomp end

    def config_file; root.join('.cnfs') end

    def config_dir; gem_root.join('config') end

    def project_config_dir; root.join('cnfs_config') end

    def xdg; @xdg ||= XDG::Environment.new end

    # TODO: rather than Dir.pwd should take from the Platform method that calculates project dir
    def root; Pathname.new(Dir.pwd) end

    def cnfs_project?; File.exist?(config_file) end

    def cnfs_services_project?; File.exist?(root.join('lib/core/lib/ros/core.rb')) end

    def gem_root; Pathname.new(File.expand_path('../..', __FILE__)) end

    def encrypt(value, strip_yaml = false)
      value = box.encrypt(value).to_yaml
      strip_yaml ? value.gsub("--- !binary |-\n  ", '').chomp : value
    end

    def decrypt(value, add_yaml = false)
      value = add_yaml ? "--- !binary |-\n  #{value}\n" : value
      box.decrypt(YAML.load(value))
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
    def setup(skip_schema = false)
      plugins.each { |plugin| load_plugin(plugin) }
      # Zeitwerk::Loader.default_logger = method(:puts)
      autoload_dirs.each { |dir| loader.push_dir(dir) }

      loader.enable_reloading
      loader.setup
      plugins.each { |plugin| plugin_after_initialize(plugin) }
      Schema.setup unless skip_schema
    end

    def reload
      Schema.reload
      loader.reload
    end

    # TODO: remove lib; only load app dirs; core/schema.rb should still be reloaded
    def autoload_dirs; @autoload_dirs ||= ["#{gem_root}/lib", "#{gem_root}/app/controllers", "#{gem_root}/app/models", "#{gem_root}/app/generators"] end

    def add_plugins(list); self.plugins += list end

    def plugins; @plugins ||= [] end

    def gid
      ext_info = OpenStruct.new
      if (RbConfig::CONFIG['host_os'] =~ /linux/ and Etc.getlogin)
        shell_info = Etc.getpwnam(Etc.getlogin)
        ext_info.puid = shell_info.uid
        ext_info.pgid = shell_info.gid
      end
      ext_info
    end

    # TODO: determine how plugins are discovered and loaded
    # How are plugins declared?
    # def config_file; 'config/cnfs.yml' end

    # def settings; @settings ||= Config.load_and_set_settings(config_file) end

    # def plugins; @plugins ||= (%w[cnfs-core cnfs cnfs-ext] + (settings.plugins || [])) end
    # def plugins; @plugins ||= %w[cnfs-core cnfs cnfs-ext] end
    # def plugins; @plugins ||= %w[cnfs-core cnfs] end
    # def plugins; @plugins ||= %w[cnfs cnfs-ext] end

    # require any plugins listed in config/cnfs.yml and add each gem's lib path to Zeitwerk
    # NOTE: this currently only works with gems laid out in the same top level dir
    # TODO: get this to work with a real gem based plugin structure

    # def require_core
    #   plugin = 'cnfs-core'
    #   lib_path = File.expand_path("../../#{plugin}/lib", __dir__)
    #   $:.unshift(lib_path) if !$:.include?(lib_path)
    #   plugin_module = plugin.gsub('-', '/')
    #   require plugin_module
    # end
  end
end
