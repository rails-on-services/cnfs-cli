# frozen_string_literal: true

require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

require 'lockbox'
require 'tty-tree'

require_relative 'ext/pathname'
require_relative 'solid_record/tree_view'
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

    def config() = @config ||= config_set

    def config_set
      config = ActiveSupport::OrderedOptions.new
      config.document_map = { yml: :yaml, yaml: :yaml }
      # config.encryption_key = Lockbox.generate_key
      config.flush_cache_on_exit = true
      config.raise_on_error = false
      config.reference_suffix = :name
      # config.sandbox = true
      config.schema_file = nil # Path to a file that defines an ActiveRecord::Schema
      config
    end
  end
end

require_relative 'solid_record/extension' if defined? SolidSupport

require_relative 'solid_record/data_store'
require_relative 'solid_record/load_path'

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
  end

  SolidRecord.logger.formatter = SimpleFormatter
end

Kernel.at_exit { SolidRecord::DataStore.at_exit }
