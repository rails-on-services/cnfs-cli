# frozen_string_literal: true

module SolidRecord
  class << self
    def data_store() = @data_store ||= DataStore.new
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

    attr_accessor :model_names, :model_dirs, :log_migrations, :assets_to_disable

    def initialize(**options)
      @log_migrations = options.fetch(:log_migrations, false)
      @model_names = options.fetch(:model_names, [])
      @model_dirs = options.fetch(:model_dirs, [])
      [model_dirs].flatten.each do |dir|
        path = Pathname.new(dir)
        @model_names += path.glob('**/*.rb').map do |model|
          model.relative_path_from(path).to_s.delete_suffix('.rb')
        end
      end
    end

    def setup
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      create_database_tables
      true
    end

    def reset() = create_database_tables

    # TODO: Finish this
    def with_asset_callbacks_disabled
      Node.source = :node

      assets_to_disable.each do |asset|
        asset.node_callbacks.each { |callback| asset.skip_callback(*callback) }
      end

      yield

      assets_to_disable.each do |asset|
        asset.node_callbacks.each { |callback| asset.set_callback(*callback) }
      end

      Node.source = :asset
    end


    private

    def create_database_tables
      ActiveRecord::Migration.verbose = log_migrations
      SolidRecord::DataStore.model_names = model_names
      ActiveRecord::Schema.define do |schema|
        SolidRecord::DataStore.model_names.each do |model_name|
          model = model_name.classify.constantize
          model.create_table(schema)
          model.reset_column_information
        end
      end
    end
  end
end
