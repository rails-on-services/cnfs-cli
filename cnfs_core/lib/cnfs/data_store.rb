# frozen_string_literal: true

module Cnfs
  class DataStore
    class << self
      attr_accessor :model_names
    end

    def model_names
      @model_names ||= []
    end

    def add_models(*model_list)
      model_names.concat(model_list.flatten)
    end

    def setup
      Cnfs.with_timer('database initialization') do
        # Set up in-memory database
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        create_database_tables
      end
      true
    end

    def reload
      Cnfs.with_timer('database reload') do
        # Remove any A/R Cached Classes (e.g. STI classes)
        ActiveSupport::Dependencies::Reference.clear!
        create_database_tables
      end
      true
    end

    private

    def create_database_tables
      Cnfs::DataStore.model_names = model_names
      Cnfs.silence_output do
        ActiveRecord::Schema.define do |s|
          Cnfs::DataStore.model_names.each do |model_name|
            model = model_name.classify.constantize
            model.create_table(s)
            model.reset_column_information
          end
        end
      end
    end
  end
end
