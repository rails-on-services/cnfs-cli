# frozen_string_literal: true

module SolidRecord
  class << self
    def status = @status || (@status = ActiveSupport::StringInquirer.new(''))

    def status=(value)
      @status = ActiveSupport::StringInquirer.new(value)
    end

    def load() = DataStore.load()

    def reload() = DataStore.load()

    def reset2() = DataStore.reset()
  end

  class DataStore
    class << self
      def load
        ActiveRecord::Migration.verbose = defined?(SPEC_ROOT) ? false : SolidRecord.logger.level.eql?(0)
        SolidRecord.config.schema_file ? load(SolidRecord.config.schema_file) : create_schema_from_tables
        LoadPath.load_all
        true
      end

      def reset
        if SolidRecord.config.sandbox
          tmp_path.rmtree
          tmp_path.mkpath
        end
        SolidRecord.config.load_paths = []
        self.load
      end

      def flush_cache
        ModelElement.flagged_for(:destroy).each(&:destroy)
        Document.flagged.each(&:write)
        Element.update_all(flags: nil)
      end

      def at_exit
        flush_cache if SolidRecord.status.loaded? && SolidRecord.config.flush_cache_on_exit
        tmp_path.rmtree if SolidRecord.config.sandbox && tmp_path.exist?
      end

      def tmp_path() = @tmp_path ||= Pathname.new(Dir.mktmpdir)

      def create_schema_from_tables
        ActiveRecord::Schema.define do |schema|
          require_relative '../ext/table_definition'
          SolidRecord.tables.select { |table| table.respond_to?(:create_table) }.each do |table|
            table.create_table(schema)
            table.reset_column_information
          end
        end
      end

      # Dump the latest version of the schema to a file
      #
      # Create a schema which can be used with NullDB to emulate models without having
      # the actual classes or underlying database prsent
      def schema_dump(file_name = nil)
        schema = ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, StringIO.new).string
        return schema unless file_name

        File.open(file_name, 'w') { |f| f.puts(schema) }
      end
    end
  end
end
