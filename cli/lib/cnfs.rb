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

require_relative 'cnfs/application'
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

  CNFS_DIR = '.cnfs'
  class << self
    attr_accessor :autoload_dirs, :context_name # , :skip_schema
    attr_accessor :context, :key
    attr_reader :application

    def lite_setup
      ENV['CNFS_DEV'] ? initialize_dev_plugins : initialize_plugins
      setup_loader
    end

    def setup
      app_file = app_path.join(CNFS_DIR).join('config/application.rb')
      require app_file if File.exist? app_file
      return unless (@application = Cnfs::Application.descendants.shift&.new(app_path))

      # Modify priority of db and app/views paths by inserting gem and plugin paths before application and user paths
      current_paths = application.paths.dup
      application.paths['db'] = [gem_root.join('db')]
      application.paths['app/views'] = [gem_root.join('app/views')]
      application.config.dev ? initialize_dev_plugins : initialize_plugins
      application.paths['db'] += current_paths['db']
      application.paths['app/views'] += current_paths['app/views']

      setup_loader
    end

    def app_path
      @app_path ||= Pathname.new(Dir.pwd).ascend { |path| break path if path.join(CNFS_DIR).directory? }
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

    # NOTE: Dir.pwd is the current application's root (switched into)
    # TODO: This should probably move out to rails or some other place
    def services_project?
      File.exist?(Pathname.new(Dir.pwd).join('lib/core/lib/ros/core.rb'))
    end

    # def gem_db_path
    #   @gem_db_path ||= gem_root.join('db')
    # end

    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
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
      application.reload
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

    def platform
      case RbConfig::CONFIG['host_os']
      when /linux/
        'linux'
      when /darwin/
        'darwin'
      end
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
