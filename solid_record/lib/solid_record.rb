# frozen_string_literal: true

require 'active_record'
require 'sqlite3'

require 'solid_support'

require_relative 'solid_record/version'
require_relative 'solid_record/extension' if defined? Hendrix
require_relative 'solid_record/data_store'

require_relative 'solid_record/table'
require_relative 'solid_record/data_path'
require_relative 'solid_record/document'
require_relative 'solid_record/element'
require_relative 'solid_record/root_element'

require_relative 'solid_record/yaml_document'

require_relative 'solid_record/persistence'
require_relative 'solid_record/model'

# @example Usage
#   SolidRecord.load
module SolidRecord

  class ColorFormatter < Logger::Formatter
    class << self
      def call(severity, timestamp, progname, msg)
        ActiveSupport::LogSubscriber.new.send(:color, "#{timestamp}, #{severity}: #{msg}\n", color(severity))
      end

      def color(severity)
        case severity
        when 'FATAL'
          :red
        when 'WARN'
          :yellow
        when 'INFO'
          :green
        end
      end
    end
  end

  # Simple formatter which only displays the message.
  class SimpleFormatter < ::Logger::Formatter
    # This method is invoked when a log event occurs
    def self.call(severity, timestamp, progname, msg)
      "#{String === msg ? msg : msg.inspect}\n"
    end
  end

  class << self
    attr_writer :logger

    def logger() = @logger ||= ActiveSupport::Logger.new(STDOUT)

    def load(**options)
      [DataStore, DataPath.create(**options)].each(&:load)
      true
    end
  end

  SolidRecord.logger.formatter = SimpleFormatter

  class Error < StandardError; end
end
