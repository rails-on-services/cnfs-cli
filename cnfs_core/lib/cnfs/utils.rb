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

    # Cnfs.logger.compare_levels(:info, :debug) => :gt
    def silence_output(unless_logging_at = :debug)
      rs = $stdout
      $stdout = StringIO.new if logger.compare_levels(config.logging, unless_logging_at).eql?(:gt)
      yield
      $stdout = rs
    end

    def cli_mode
      @cli_mode ||= set_cli_mode
    end

    def set_cli_mode
      mode = config.dev ? 'development' : 'production'
      ActiveSupport::StringInquirer.new(mode)
    end
  end
end
