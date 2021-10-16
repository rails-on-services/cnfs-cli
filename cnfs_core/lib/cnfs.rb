# frozen_string_literal: true

require 'config'
require 'tty-logger'
require 'xdg'

require_relative 'cnfs/boot'
require_relative 'cnfs/context'
require_relative 'cnfs/loader'

# rubocop:disable Metrics/ModuleLength
module Cnfs
  # class Error < StandardError; end

  class << self
    attr_accessor :plugin_root

    def config
      @config ||= context.config
    end

    def data_store
      @data_store ||= Cnfs::DataStore.new
    end

    def logger
      @logger ||= set_logger
    end

    def set_logger
      TTY::Logger.new do |cfg|
        level = TTY::Logger::LOG_TYPES.keys.include?(config.logging.to_sym) ? config.logging.to_sym : :warn
        config.logging = cfg.level = level
      end
    end

    def timers
      @timers ||= {}
    end

      def require_deps(type = :minimum)
        Cnfs.with_timer('loading minimum dependencies') { require_relative 'cnfs/minimum_dependencies' }
        Cnfs.with_timer('loading core dependencies') { require_relative 'cnfs/dependencies' } if type.eql?(:all)
        # TODO: Refector to move to the appropriate gem using AS Notifications
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.uncountable %w[aws cnfs dns kubernetes postgres rails redis]
        end
      end

    def reload
      @config = nil
      context.reload
      binding.pry
      loader.reload
      data_store.reload
    end

    # NOTE: most of this moved to context. Is shift and caps needed?
    def reset
      ARGV.shift # remove 'new'
      # TODO: project_root is in cli gem
      # @project_root = nil
      # @paths = nil
      @capabilities = nil
      # Dir.chdir(project_root) { load_config }
    end

    def loader
      @loader ||= Cnfs::Loader.new(logger: logger)
    end

    def gem_root
      @gem_root ||= Pathname.new(__dir__).join('..')
    end

    def extensions
      @extensions ||= []
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

    # TODO: make the 'cnfs' configurable from cnfs-cli
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
