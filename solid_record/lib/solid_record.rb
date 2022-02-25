# frozen_string_literal: true

require 'active_record'
require 'lockbox'
require 'sqlite3'

require 'solid_support'

require_relative 'solid_record/version'

# <table>
# <tr> | First Header  | Second Header | </tr>
# | ------------- | ------------- |
# | Content Cell  | Content Cell  |
# | Content Cell  | Content Cell  |
# <table>

module SolidRecord
  class Error < StandardError; end

  class << self
    attr_writer :logger

    def config() = @config ||= ActiveSupport::OrderedOptions.new
  end
end

require_relative 'solid_record/extension' if defined? Hendrix

require_relative 'solid_record/data_store'

require_relative 'solid_record/table'
require_relative 'solid_record/element'

require_relative 'solid_record/file_system_element'
require_relative 'solid_record/path'

require_relative 'solid_record/association'
require_relative 'solid_record/document'

require_relative 'solid_record/model_element'
require_relative 'solid_record/root_element'

require_relative 'solid_record/encryption'
require_relative 'solid_record/persistence'
require_relative 'solid_record/model'

module SolidRecord
  class ColorFormatter < Logger::Formatter
    class << self
      def call(severity, timestamp, _progname, msg)
        ActiveSupport::LogSubscriber.new.send(:color, "#{timestamp}, #{severity}: #{msg}\n", color(severity))
      end

      def color(severity) = { 'FATAL' => :red, 'WARN' => :yellow, 'INFO' => :green }[severity]
    end
  end

  # Simple formatter which only displays the message.
  class SimpleFormatter < ::Logger::Formatter
    # This method is invoked when a log event occurs
    def self.call(_severity, _timestamp, _progname, msg)
      "#{msg.is_a?(String) ? msg : msg.inspect}\n"
    end
  end

  class << self
    def logger() = @logger ||= ActiveSupport::Logger.new($stdout)

    def raise_or_warn(err, warn = nil)
      raise err if SolidRecord.config.raise_on_error

      SolidRecord.logger.warn { warn || err.message }
      SolidRecord.logger.debug { err.backtrace.join("\n") } if err.backtrace
      nil
    end

    def flush_cache
      ModelElement.flagged_for(:destroy).each(&:destroy)
      Document.flagged.each(&:write)
      # cache_destroy
      # cache_write
    end

    def cache_destroy() = ModelElement.flagged_for(:destroy).each(&:destroy)

    def cache_write() = Document.flagged.each(&:write)
  end

  SolidRecord.logger.formatter = SimpleFormatter
end

Kernel.at_exit { SolidRecord.flush_cache } if SolidRecord.config.flush_cache
