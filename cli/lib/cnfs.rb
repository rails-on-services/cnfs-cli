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
    PROJECT_FILE = '.cnfs'
    CONFIG_FILE = 'cnfs.yml'
    attr_reader :project_file, :project_name
    attr_accessor :autoload_dirs, :context_name, :skip_schema
    attr_reader :root, :config_path, :user_root, :user_config_path
    attr_accessor :request, :response, :key

    def setup(lite = false)
      project_dir = Pathname.new(Dir.pwd).ascend { |dir| break dir if File.exist?("#{dir}/#{PROJECT_FILE}") }
      lite = true if project_dir.nil?
      @skip_schema = lite # for plugins. necessary?
      ENV['CNFS_DEV'] = '1' if ARGV.delete('--dev')
      setup_paths(project_dir || Dir.pwd)
      load_project_config
      config.dev ? initialize_dev_plugins : initialize_plugins
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
          $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
          require plugin_module
          next unless (klass = plugin_module.camelize.safe_constantize)

          klass.setup
        end
      end
    end

    def setup_paths(project_path)
      @root = Pathname.new(project_path)
      @config_path = root.join('config')

      @project_file = root.join(PROJECT_FILE)
      return unless File.exist? @project_file

      @project_name = File.read(@project_file).chomp

      @user_root = xdg.config_home.join('cnfs').join(project_name)
      @user_config_path = user_root.join('config')
    end

    def load_project_config
      if File.exist? project_file
        Config.load_and_set_settings(root.join(CONFIG_FILE), user_root.join(CONFIG_FILE))
      else
        Config.load_and_set_settings('')
      end
    end

    def config
      Settings
    end

    def context
      Context.find_by(name: config.context)
    end

    def project?
      File.exist?(project_file)
    end

    # NOTE: Dir.pwd is the current application's root (switched into)
    # TODO: This should probably move out to rails or some other place
    def services_project?
      File.exist?(Pathname.new(Dir.pwd).join('lib/core/lib/ros/core.rb'))
    end

    def gem_config_path
      @gem_config_path ||= gem_root.join('config')
    end

    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
    end

    def xdg
      @xdg ||= XDG::Environment.new
    end

    def debug
      ARGV.include?('-d') ? ARGV[ARGV.index('-d') + 1].to_i : 0
    end

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

    def loader
      @loader ||= Zeitwerk::Loader.new
    end

    def autoload_dirs
      @autoload_dirs ||= autoload_all(gem_root)
    end

    def autoload_all(path)
      %w[controllers models generators].each_with_object([]) { |type, ary| ary << path.join('app').join(type) }
    end

    # Utility methods
    # Configuration fixture file loading methods
    def load_configs(file)
      STDOUT.puts "Loading config file #{file}" if Cnfs.debug > 0
      config_dirs.each_with_object([]) { |path, ary| ary << load_config(file, path) }.join("\n")
    end

    def config_dirs
      @config_dirs ||= [config_path, user_config_path]
    end

    def load_config(file, path)
      fixture_file = path.join(File.basename(file))
      return unless File.exist?(fixture_file)

      STDOUT.puts "Loading config file #{fixture_file}" if debug > 0

      ERB.new(IO.read(fixture_file)).result.gsub("---\n", '')
    end

    def controllers
      @controllers ||= []
    end

    # Lockbox encryption methods
    def box
      @box ||= Lockbox.new(key: key&.value)
    end

    def key=(name)
      @box = nil
      @key = Key.find_by(name: name)
      STDOUT.puts "WARN: Invalid Key. Valid keys: #{Key.pluck(:name).join(', ')}" if @key.nil?
    end

    def encrypt_file(file_name)
      plaintext = File.read(file_name)
      File.open("#{file_name}.enc", 'w') { |f| f.write(Cnfs.box.encrypt(plaintext)) }
    end

    def decrypt_file(file_name)
      ciphertext = File.binread(file_name)
      box.decrypt(ciphertext).chomp
    end

    # OS methods
    def gid
      ext_info = OpenStruct.new
      if RbConfig::CONFIG['host_os'] =~ /linux/ && Etc.getlogin
        shell_info = Etc.getpwnam(Etc.getlogin)
        ext_info.puid = shell_info.uid
        ext_info.pgid = shell_info.gid
      end
      ext_info
    end

    def git_details
      return Config::Options.new unless system('git rev-parse --git-dir > /dev/null 2>&1')

      Config::Options.new(
        tag_name: `git tag --points-at HEAD`.chomp,
        branch_name: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
        sha: `git rev-parse --short HEAD`.chomp
      )
    end

    def silence_output(enforce)
      rs = $stdout
      $stdout = StringIO.new if enforce
      yield
      $stdout = rs
    end
  end
end
