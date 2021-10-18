# frozen_string_literal: true

module Cnfs
  class << self

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

    # def tools
    #   Dependency.pluck(:name)
    # end

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
  end
end
