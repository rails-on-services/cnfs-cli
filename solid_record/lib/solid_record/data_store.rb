# frozen_string_literal: true

module SolidRecord
  class << self
    def tmp_path() = @tmp_path ||= Pathname.new(::Dir.mktmpdir)

    def status = @status || (@status = ActiveSupport::StringInquirer.new(''))

    def status=(value)
      @status = ActiveSupport::StringInquirer.new(value.to_s)
    end

    def setup
      ActiveRecord::Migration.verbose = defined?(SPEC_ROOT) ? false : logger.level.eql?(0)
      config.schema_file ? load(config.schema_file) : DataStore.create_schema_from_tables
      self.status = :unloaded
    end

    def load
      clean unless status.unloaded?
      setup
      self.status = :loading
      # toggle_callbacks do
        config.load_paths.each do |path|
          lp = Path.add(source: path)
          raise_or_warn(StandardError.new(lp.errors.full_messages.join("\n"))) unless lp.persisted?
        end
      # end
      self.status = :loaded
      true
    end

    def toggle_callbacks(&block)
      with_model_element_callbacks do
        skip_persistence_callbacks(&block)
      end
    end

    def clean(make: config.sandbox)
      tmp_path.rmtree if tmp_path.exist? && tmp_path.children.size.positive?
      tmp_path.mkpath if make
    end

    def at_exit
      # This is called even when using Kernel.exit
      flush_cache if status.loaded? && config.flush_cache_on_exit
      clean(make: false)
    end

    def flush_cache
      Element.flagged_for(:destroy).each(&:destroy)
      File.flagged.each(&:write)
      Segment.update_all(flags: nil)
    end
  end

  class DataStore
    class << self
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
