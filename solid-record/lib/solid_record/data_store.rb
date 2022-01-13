# frozen_string_literal: true

# Simple Usage:
#   SolidRecord.configure.load
#
# Usage:
#   SolidRecord.configure(schema_paths: 'app/models')
#   SolidRecord.data_paths += SolidRecord::PathMap.new(path: 'spec/dummy/data', map: { '.' => 'segments' })
#   SolidRecord.load

module SolidRecord
  class << self
  def parser_map
    {
      yml: :yaml,
      yaml: :yaml
    }
  end
  end
  # path: 'spec/dummay/data'
  # layout:
  # backend/development
  # backend/production/cluster
  # frontend/cluster
  #
  # 1. Single class at all levels of hierarchy (i.e. self referencing)
  #    Required models: Segment
  #    map: { '.' => 'segments' }
  #
  # 2. Consistent map of hierarchy paths to classes
  #    Required models Stack, Environment, Target
  #    map: { '.' => 'stacks', 'stacks' => 'environments', 'stacks/environments' => 'targets' }
  #
  # 3. Each path within the hierarchy has it's own class hierarchy
  #    Required models Stack, Environment, Target
  #    map: { '.' => 'stacks', 'frontend' => 'target', 'backend' => 'environments', backend/production' => 'target' })
  #
  # 4. Default
  #    Required models: path.basename.to_s.classify
  #    map: {}
  #
  class << self
    attr_writer :data_paths, :glob_pattern

    # array of PathMap classes
    def data_paths() = @data_paths ||= []

    def glob_pattern() = @glob_pattern ||= '**/*.yml'

    def configure(**options)
      DataStore.configure(**options)
      @data_paths ||= [options[:data_paths]].compact.flatten
      self
    end

    def load
      DataStore.load
      data_paths.append(new) if data_paths.empty?
      data_paths.each(&:load_path)
    end
  end

  class PathMap
    attr_accessor :path, :map, :pattern

    def initialize(**options)
      @path = Pathname.new(options.fetch(:path, '.'))
      @map = options.fetch(:map, {})
      @pattern = options.fetch(:pattern, SolidRecord.glob_pattern)
    end

    def load_path
      # TODO: Convert path.basename.to_s to a class using map
      # TODO: Log a warning when a file is not converted; Config setting to disable warnings
      path.glob(pattern).each do |entry|
        next unless (klass = entry.classify.safe_constantize)

        klass.load_content(entry)
      end
    end
  end

  class DataStore
    class << self
      # schema_file: path to a file that defines an ActiveRecord::Schema
      # schema_paths: array of paths to models which implement create_table 
      attr_accessor :schema_file, :schema_paths

      def configure(**options)
        ActiveRecord::Migration.verbose = options.fetch(:verbose, false)
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        @schema_file = options.fetch(:schema_file, nil)
        @schema_paths = [options[:schema_paths]].compact.flatten
        self
      end

      # Use this method to dump the latest version of the schema to a file
      # Gems can use this to create a schema that used with NullDB to emulate models without having the actual classes
      # or underlying database prsent
      def schema_dump(file_name = nil)
        schema = ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, StringIO.new).string
        return schema unless file_name

        File.open(file_name, 'w') { |f| f.puts(schema) }
      end

      def load
        if schema_file
          require schema_file
        else
          load_schema_paths
        end
      end

      def reset() = load_schema_paths

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

      def schema_model_names
        schema_paths.each_with_object([]) do |schema_path, ary|
          path = Pathname.new(schema_path)
          path.glob('**/*.rb').map do |model|
            ary.append model.relative_path_from(path).to_s.delete_suffix('.rb')
          end
        end
      end
    end
  end
end
