# frozen_string_literal: true

module Cnfs
  class << self
    def data_store() = @data_store ||= DataStore.new
    # def reset() = data_store.reload # create_database_tables
  end

  class DataStore
    class << self
      # This class accessor is used in #create_database_tables
      attr_accessor :model_names

      # Use this method to dump the latest version of the schema to a file
      # Gems can use this to create a schema that used with NullDB to emulate models without having the actual classes
      # or underlying database prsent
      def schema_dump(file_name = nil)
        schema = ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, StringIO.new).string
        return schema unless file_name

        File.open(file_name, 'w') { |f| f.puts(schema) }
      end
    end

    def model_names() = @model_names ||= []

    def add_models(*model_list) = model_names.concat(model_list.flatten)

    def setup
      Cnfs.with_timer('database initialization') do
        require 'active_record'
        # ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: Cnfs.config.data_home.join('sqlite.db'))
        # Set up in-memory database
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        create_database_tables
      end
      true
    end

    def reset() = create_database_tables
      # Cnfs.with_timer('database reload') do
      #   # Remove any A/R Cached Classes (e.g. STI classes)
      #   ActiveSupport::Dependencies::Reference.clear!
      #   create_database_tables
      # end
      # true
    # end

    private

    def create_database_tables
      ActiveRecord::Migration.verbose = log_migrations?
      Cnfs::DataStore.model_names = model_names
      ActiveRecord::Schema.define do |s|
        Cnfs::DataStore.model_names.each do |model_name|
          model = model_name.classify.constantize
          model.create_table(s)
          model.reset_column_information
        end
      end
    end

    def log_migrations?
      Cnfs.logger.compare_levels(Cnfs.logger.instance_variable_get('@config').level, :debug).eql?(:eq)
    end
  end
end
