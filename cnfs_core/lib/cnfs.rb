# frozen_string_literal: true

require 'config'
require 'tty-logger'
require 'xdg'

require_relative 'cnfs/boot'

# rubocop:disable Metrics/ModuleLength
module Cnfs
  # class Error < StandardError; end

  class << self
    # attr_accessor :repository, :project
    attr_accessor :project
    # Injected values
    attr_accessor :project_file, :plugin_root
    attr_reader :config, :timers, :logger, :cwd

    attr_accessor :project_root, :config, :logger
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize!
      @timers = {}
      @cwd = Pathname.new(Dir.pwd)
    end

    # def prepare_fixtures(models)
    #   models.each(&:parse)
    # end

    # return true if the directory from which the command was invoked is not inside an existing project
    def cwd_outside_project?
      Cnfs.project_root.nil?
    end

    def parsable_files
      @parsable_files ||= source_files.group_by { |path| path.split('/').last.delete_suffix('.yml') }
    end

    def source_files
      @source_files ||= source_paths_map.values.flatten.map { |path| Dir[path.join('config', '**/*.yml')] }.flatten
    end

    # For each valid key, return an internal list of paths to search including all plugins
    # NOTE: Could include repositories
    def source_paths_map
      @source_paths_map ||= {
        cli: [plugin_root.gem_root],
        plugins: plugin_root.plugins.values.map { |p|
          p.to_s.split('::').reject{ |n| n.eql?('Plugins') }.join('::').safe_constantize.gem_root
        },
        project: [project_root],
        user: [user_root.join(config.name)]
      }
    end

    def initialize_development
      # require 'pry'
      # initialize_dev_plugins
    end

    # def initialize_repositories
    #   return unless Cnfs.paths.src.exist?

    #   Cnfs.paths.src.children.select(&:directory?).each do |repo_path|
    #     repo_config_path = repo_path.join('cnfs/repository.yml')
    #     Cnfs.logger.info "Scanning repository path #{repo_path}"
    #     next unless repo_config_path.exist? && (name = YAML.load_file(repo_config_path)['name'])

    #     Cnfs.logger.info "Loading repository path #{repo_path}"
    #     config = YAML.load_file(repo_config_path).merge(path: repo_path)
    #     repositories[name.to_sym] = Thor::CoreExt::HashWithIndifferentAccess.new(config)
    #   end
    #   @repository = current_repository
    #   Cnfs.logger.info "Current repository set to #{repository&.name}"
    # end

    def reload
      reset
      loader.reload
      Cnfs::Configuration.reload
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
      @project_root ||= cwd.ascend { |path| break path if path.join(project_file).file? }
    end

    def paths
      @paths ||= config.paths.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
    end

    def autoload_all(path)
      return [] unless path.join('app').exist?

      path.join('app').children.select(&:directory?).select { |m| default_load_paths.include?(m.split.last.to_s) }
    end

    def default_load_paths
      %w[controllers generators helpers models views]
    end

    def extensions
      @extensions ||= []
    end

    def valid_top_level_command?
      # Display help for new command when no arguments are passed
      ARGV.append('help', 'new') if ARGV.size.zero?
      %w[dev help new version].each do |valid_command|
        break [valid_command] if valid_command.start_with?(ARGV[0])
      end.size.eql?(1)
    end

    def reset
      ARGV.shift # remove 'new'
      @cwd = Pathname.new(Dir.pwd)
      @project_root = nil
      @paths = nil
      @capabilities = nil
      Dir.chdir(project_root) { load_config }
    end

    def with_timer(title = '', level = :info)
      start_time = Time.now
      logger.send(level, "Start #{title} at #{start_time}")
      yield
      timers[title] = Time.now - start_time
      logger.send(level, "Completed #{title} in #{Time.now - start_time} seconds")
    end

    # OS methods
    def gid
      ext_info = OpenStruct.new
      if platform.linux? && Etc.getlogin
        shell_info = Etc.getpwnam(Etc.getlogin)
        ext_info.puid = shell_info.uid
        ext_info.pgid = shell_info.gid
      end
      ext_info
    end

    def capabilities
      @capabilities ||= set_capabilities
    end

    # rubocop:disable Metrics/MethodLength
    def set_capabilities
      cmd = TTY::Command.new(printer: :null)
      installed_tools = []
      missing_tools = []
      tools.each do |tool|
        if cmd.run!("which #{tool}").success?
          installed_tools.append(tool)
        else
          missing_tools.append(tool)
        end
      end
      Cnfs.logger.warn "Missing dependency tools: #{missing_tools.join(', ')}" if missing_tools.any?
      installed_tools
    end
    # rubocop:enable Metrics/MethodLength

    def tools
      Dependency.pluck(:name)
    end

    def platform
      os =
        case RbConfig::CONFIG['host_os']
        when /linux/
          'linux'
        when /darwin/
          'darwin'
        else
          'unknown'
        end
      ActiveSupport::StringInquirer.new(os)
    end

    def cli_mode
      @cli_mode ||= begin
        mode = config.dig(:cli, :dev) ? 'development' : 'production'
        ActiveSupport::StringInquirer.new(mode)
      end
    end

    def git
      return OpenStruct.new(sha: '', branch: '') unless system('git rev-parse --git-dir > /dev/null 2>&1')

      OpenStruct.new(
        branch: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
        sha: `git rev-parse --short HEAD`.chomp,
        tag: `git tag --points-at HEAD`.chomp
      )
    end

    # Cnfs.logger.compare_levels(:info, :debug) => :gt
    def silence_output(unless_logging_at = :debug)
      rs = $stdout
      $stdout = StringIO.new if logger.compare_levels(config.logging, unless_logging_at).eql?(:gt)
      yield
      $stdout = rs
    end

    def config_paths
      @config_paths = [plugin_root.gem_root.join(project_file), user_root.join('cnfs.yml'), project_file]
    end

    def user_root
      @user_root ||= xdg.config_home.join('cnfs')
    end

    def user_data_root
      @user_data_root ||= xdg.data_home.join('cnfs')
    end

    def xdg
      @xdg ||= XDG::Environment.new
    end
  end
end
# rubocop:enable Metrics/ModuleLength
