# frozen_string_literal: true
require 'little-plugger'
require 'pathname'

module Cnfs
  extend LittlePlugger
  module Plugins; end

  class Error < StandardError; end

  class << self
    attr_accessor :autoload_dirs, :pwd
    attr_reader :project, :config, :project_root, :repository_root
    PROJECT_FILE = 'lib/project.rb'

    def reset
      ARGV.shift # remove 'new'
      @pwd = Pathname.new(Dir.pwd)
      @project_root = nil
      @repository_root = nil
      @project = nil
      Dir.chdir(project_root) do
        load_config
      end
    end

    def initialize!
      @pwd = Pathname.new(Dir.pwd)
      raise Cnfs::Error, 'Not a cnfs project' unless project_root
      s = Time.now
      Dir.chdir(project_root) do
        require_minimum_deps
        load_config
        if config.dig(:cli, :dev)
          require 'pry'
          initialize_dev_plugins
        else
          initialize_plugins
        end
        setup_loader
        PrimaryController.start
      end
      puts "Wall time: #{Time.now - s}" if config.debug.positive?
    end

    def require_minimum_deps
      require 'active_support/inflector'
      require 'active_support/core_ext/hash/keys'
      require 'config'
      require 'fileutils'
      require 'thor'
      require 'xdg'
      require 'zeitwerk'

      require_relative 'cnfs/errors'
      require_relative 'cnfs/version'
      require_relative 'ext/config/options'
      require_relative 'ext/string'

      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable %w[cnfs]
      end
    end

    def require_deps
      puts 'Loading dependencies...' if config.debug.positive?
      s = Time.now
      require 'active_record'
      require 'active_record/fixtures'
      require 'active_support/core_ext/enumerable'
      require 'active_support/log_subscriber'
      require 'active_support/string_inquirer'
      # require 'json_schemer'
      require 'rails/railtie' # required before lockbox
      require 'lockbox'
      require 'open-uri'
      # require 'open3'
      require 'sqlite3'

      require_relative 'cnfs/project'
      require_relative 'cnfs/schema'
      puts "Loaded in #{Time.now - s} seconds" if config.debug.positive?
    end

    def load_config
      Config.env_separator = '_'
      Config.env_prefix = 'CNFS'
      Config.use_env = true
      ENV['CNFS_ENVIRONMENT'] = ENV.delete('CNFS_ENV')
      ENV['CNFS_NAMESPACE'] = ENV.delete('CNFS_NS')
      @config = Config.load_files(gem_root.join('config', 'cnfs.yml'), user_root.join('cnfs.yml'), 'cnfs.yml')
      Config.use_env = false
      config.debug ||= 0
    end

    # Emulate LittlePlugger's initialize process when in development mode
    def initialize_dev_plugins
      gem_root.join('..').children.select(&:directory?).each do |dir|
        plugin_dir = dir.join('lib/cnfs/plugins')
        next unless plugin_dir.directory?

        plugin_dir.children.each do |file|
          name = File.basename(file).delete_suffix('.rb')
          plugin_module = "cnfs/plugins/#{name}"
          lib_path = File.expand_path(dir.join('lib'))
          $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
          require plugin_module
          next unless (klass = plugin_module.camelize.safe_constantize)

          msg = "initialize_#{name}"
          klass.send msg if klass.respond_to? msg
        end
      end
    end

    # Zeitwerk based class loader methods
    def setup_loader
      Zeitwerk::Loader.default_logger = method(:puts) if config.debug > 1
      autoload_dirs.each { |dir| loader.push_dir(dir) }

      loader.enable_reloading
      loader.setup
    end

    def reload
      project&.reload
      loader.reload
    end

    def loader
      @loader ||= Zeitwerk::Loader.new
    end

    def autoload_dirs
      @autoload_dirs ||= autoload_all(gem_root)
    end

    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
    end

    def project_root
      @project_root ||= (
        return '.' if %w[dev help new version].include?(ARGV[0])

        pwd.ascend { |path| break path if path.join('cnfs.yml').file? }
      )
    end

    def repository_root
      @repository_root ||= (
        relative_path_to_src = project_root.join(paths.src).relative_path_from(pwd)
        # Example: I'm in project_root/src/api/lib/core
        # relative_path_to_src would be ../../..
        # If execution dir is a subdir of a repository then return the Pathname of the repo
        unless relative_path_to_src.to_s.end_with?(paths.src.to_s) or relative_path_to_src.to_s.eql?('.')
          pwd.join(relative_path_to_src.split.first)
        else
          # Otherwise return the Pathname of the default repository in project’s cnfs.yml 
          project_root.join(paths.src, config.repository || '')
        end
      )
    end

    def paths
      @paths ||= config.paths.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
    end

    def autoload_all(path)
      path.join('app').children.select(&:directory?).select{ |m| %w[controllers models generators].include?(m.split.last.to_s) }
    end

    def controllers
      @controllers ||= []
    end

    def require_project!(arguments:, options:, response:)
      project_file = project_root.join(PROJECT_FILE)
      return unless File.exist?(project_file)

      require project_file
      @project = Cnfs::Project.descendants.shift&.new(root: project_root, arguments: arguments, options: options, response: response)
      true
    end

    def invoke_plugins_wtih(method, *options)
      plugins_responding_to(method).each do |plugin|
        options.empty? ? plugin.send(method) : plugin.send(method, options)
      end
    end

    def plugins_responding_to(method)
      plugins.values.select{ |klass| klass.plugin_lib.respond_to?(method) }.collect{ |klass| klass.plugin_lib }
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

    def capabilities
      ary = []
      ary.append(:docker) if system('which docker')
      ary.append(:compose) if system('which docker-compose')
      ary.append(:skaffold) if system('which skaffold')
      ary.append(:git) if system('which git')
      ary.append(:ansible) if system('which ansible')
      ary.append(:terraform) if system('which terraform')
      ary
    end

    def platform
      case RbConfig::CONFIG['host_os']
      when /linux/
        'linux'
      when /darwin/
        'darwin'
      end
    end

    # def git
    #   return Config::Options.new unless system('git rev-parse --git-dir > /dev/null 2>&1')

    #   Config::Options.new(
    #     tag_name: `git tag --points-at HEAD`.chomp,
    #     branch_name: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
    #     sha: `git rev-parse --short HEAD`.chomp
    #   )
    # end

    def silence_output(enforce)
      rs = $stdout
      $stdout = StringIO.new if enforce
      yield
      $stdout = rs
    end

    def user_root
      @user_root ||= xdg.config_home.join('cnfs')
    end

    def xdg
      @xdg ||= XDG::Environment.new
    end
  end
end
