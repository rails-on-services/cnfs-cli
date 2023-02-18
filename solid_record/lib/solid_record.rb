# frozen_string_literal: true

require 'active_record'
require 'active_record/fixtures'
require 'sqlite3'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

require 'lockbox'
require 'tty-tree'

require_relative 'ext/pathname'
require_relative 'solid_record/concerns/tree_view'
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

    def config = @config ||= config_set

    def config_set
      config = ActiveSupport::OrderedOptions.new
      config.document_map = { yml: :yaml, yaml: :yaml }
      # config.encryption_key = Lockbox.generate_key
      config.flush_cache_on_exit = true
      config.raise_on_error = false
      config.reference_suffix = :name
      config.glob = '*.yml'
      config.load_paths = []
      config.class_map = {}
      # config.sandbox = true
      config.schema_file = nil # Path to a file that defines an ActiveRecord::Schema
      config
    end
  end
end

require_relative 'solid_record/concerns/extension' if defined? SolidApp

require_relative 'solid_record/data_store'

require_relative 'solid_record/concerns/table'
require_relative 'solid_record/segment'

require_relative 'solid_record/path'

require_relative 'solid_record/dir'
require_relative 'solid_record/dir_generic'
require_relative 'solid_record/dir_instance'
require_relative 'solid_record/dir_association'
require_relative 'solid_record/dir_has_many'

require_relative 'solid_record/file'
require_relative 'solid_record/concerns/a_e'
require_relative 'solid_record/association'
require_relative 'solid_record/element'

require_relative 'solid_record/concerns/encryption'
require_relative 'solid_record/concerns/persistence'
require_relative 'solid_record/concerns/model'
require_relative 'solid_record/base'

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
    def logger = @logger ||= ActiveSupport::Logger.new($stdout)

    def raise_or_warn(err, warn = nil)
      raise err if SolidRecord.config.raise_on_error

      SolidRecord.logger.warn { warn || err.message }
      SolidRecord.logger.debug { err.backtrace.join("\n") } if err.backtrace
      nil
    end
  end

  SolidRecord.logger.formatter = SimpleFormatter
end

Kernel.at_exit { SolidRecord.at_exit }
