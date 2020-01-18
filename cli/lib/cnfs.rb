# frozen_string_literal: true

require 'active_record'
require 'active_record/fixtures'
require 'active_support/inflector'
require 'active_support/string_inquirer'
require 'config'
# require 'json_schemer'
require 'little-plugger'
require 'lockbox'
require 'open-uri'
require 'pry'
# require 'open3'
require 'sqlite3'
require 'thor'
require 'xdg'
require 'zeitwerk'

require_relative 'cnfs/errors'
require_relative 'cnfs/version'
require_relative 'cnfs/schema'
require_relative 'ext/config/options'
require_relative 'ext/string'

Config.setup do |config|
  config.use_env = true
  config.env_separator = '_'
  config.env_prefix = 'CNFS'
end

module Cnfs
  extend LittlePlugger
  module Plugins; end

  class Error < StandardError; end

  class << self
    attr_accessor :autoload_dirs, :context_name
    attr_reader :root, :config_path, :config_file, :key
    attr_reader :project_name, :user_root, :user_config_path, :skip_schema

    def setup(lite = false)
      project_dir = Pathname.new(Dir.pwd).ascend { |dir| break dir if File.exist?("#{dir}/.cnfs.yml") }
      lite = true if project_dir.nil?
      @skip_schema = lite # for plugins. necessary?
      setup_paths(project_dir || Dir.pwd)
      ARGV.delete('--dev') || ENV['CNFS_DEV'] ? initialize_dev_plugins : initialize_plugins
      setup_loader
      Schema.setup unless lite
    end

    def initialize_dev_plugins
      gem_root.join('..').children.select(&:directory?).each do |dir|
        plugin_dir = dir.join('lib/cnfs/plugins')
        next unless plugin_dir.directory?

        plugin_dir.children.each do |file|
          fname = File.basename(file).delete_suffix('.rb')
          plugin_module = "cnfs/cli/#{fname}"
          lib_path = File.expand_path(dir.join('lib'))
          $:.unshift(lib_path) if !$:.include?(lib_path)
          require plugin_module
          next unless (klass = plugin_module.camelize.safe_constantize)

          klass.setup
        end
      end
    end

    def setup_paths(project_path)
      @root = Pathname.new(project_path)
      @config_path = root.join('config')
      @config_file = root.join('.cnfs.yml')

      return unless File.exist? config_file

      Config.load_and_set_settings(gem_root.join('cnfs.yml'), config_file)
      @project_name = config.name
      @user_root = xdg.config_home.join('cnfs').join(project_name)
      @user_config_path = user_root.join('config')
    end

    def config; Settings end

    def context; Context.find_by(name: config.context) end

    def project?; File.exist?(config_file) end

    # NTOE: Dir.pwd is the current application's root (switched into)
    # TODO: This should probably move out to rails or some other place
    def services_project?; File.exist?(Pathname.new(Dir.pwd).join('lib/core/lib/ros/core.rb')) end

    def gem_config_path; @gem_config_path ||= gem_root.join('config') end

    def gem_root; @gem_root ||= Pathname.new(__dir__).join('..') end

    def xdg; @xdg ||= XDG::Environment.new end

    def debug; ARGV.include?('-d') ? ARGV[ARGV.index('-d') + 1].to_i : 0 end

    # Zeitwerk based class loader methods
    def setup_loader
      Zeitwerk::Loader.default_logger = method(:puts) if debug > 1
      autoload_dirs.each { |dir| loader.push_dir(dir) }

      loader.enable_reloading
      loader.setup
    end

    def reload
      Schema.reload
      loader.reload
    end

    def loader; @loader ||= Zeitwerk::Loader.new end

    def autoload_dirs; @autoload_dirs ||= autoload_all(gem_root) end

    def autoload_all(path)
      %w[controllers models generators].each_with_object([]) { |type, ary| ary << path.join('app').join(type) }
    end

    # Utility methods
    # Configuration fixture file loading methods
    def load_configs(file)
      STDOUT.puts "Loading config file #{file}" if Cnfs.debug > 0
      config_dirs.each_with_object([]) { |path, ary| ary << load_config(file, path) }.join("\n")
    end

    def config_dirs; @config_dirs ||= [config_path, user_config_path] end

    def load_config(file, path)
      fixture_file = path.join(File.basename(file))
      return unless File.exist?(fixture_file)

      STDOUT.puts "Loading config file #{fixture_file}" if debug > 0
      ERB.new(IO.read(fixture_file)).result.gsub("---\n", '')
    end

    def controllers; @controllers ||= [] end

    # Lockbox encryption methods
    def box; @box ||= Lockbox.new(key: key.value) end

    # Set the key name to a name that is present in the Key model
    def key=(name)
      @box = nil
      @key = Key.find_by!(name: name)
    end

    # OS methods
    def gid
      ext_info = OpenStruct.new
      if (RbConfig::CONFIG['host_os'] =~ /linux/ and Etc.getlogin)
        shell_info = Etc.getpwnam(Etc.getlogin)
        ext_info.puid = shell_info.uid
        ext_info.pgid = shell_info.gid
      end
      ext_info
    end

    def silence_output(enforce)
      rs = $stdout
      $stdout = StringIO.new if enforce
      yield
      $stdout = rs
    end
  end
end
