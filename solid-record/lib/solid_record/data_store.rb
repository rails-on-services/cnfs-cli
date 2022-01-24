# frozen_string_literal: true

module SolidRecord
  class << self
    # Path to a file that defines an ActiveRecord::Schema
    attr_accessor :schema_file
    attr_accessor :verbose
  end

  class DataStore
    class << self
      def load
        ActiveRecord::Migration.verbose = SolidRecord.verbose
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        SolidRecord.schema_file ? require(schema_file) : load_schema_paths
      end

      def load_schema_paths
        ActiveRecord::Schema.define do |schema|
          require_relative '../ext/table_definition'
          SolidRecord.models.each do |model|
            next unless model.respond_to? :create_table

            model.create_table(schema)
            model.reset_column_information
          end
        end
        true
      end

      def reset() = load

      # Dump the latest version of the schema to a file
      # Example use case: Create a schema which can be used with NullDB to emulate models without having
      # the actual classes or underlying database prsent
      def schema_dump(file_name = nil)
        schema = ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, StringIO.new).string
        return schema unless file_name

        File.open(file_name, 'w') { |f| f.puts(schema) }
      end
    end
  end
end
