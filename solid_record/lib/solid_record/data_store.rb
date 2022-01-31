# frozen_string_literal: true

module SolidRecord
  class << self
    # Path to a file that defines an ActiveRecord::Schema
    attr_accessor :schema_file

    # Output table migrations
    attr_accessor :verbose
  end

  class DataStore
    class << self
      def load
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        reset
      end

      def reset() = SolidRecord.schema_file ? require(schema_file) : create_schema_from_tables

      def create_schema_from_tables
        ActiveRecord::Migration.verbose = SolidRecord.verbose
        ActiveRecord::Schema.define do |schema|
          require_relative '../ext/table_definition'
          SolidRecord.tables.each do |table|
            next unless table.respond_to? :create_table

            table.create_table(schema)
            table.reset_column_information
          end
        end
        true
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
