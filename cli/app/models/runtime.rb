# frozen_string_literal: true

class Runtime < ApplicationRecord
  include Concerns::Asset
  include Concerns::BuilderRuntime

  store :config, accessors: %i[version], coder: YAML

  # parse_sources :cli

  # Content related commands
  def labels(labels)
    project.labels.merge(labels)
  end

  def path(path = :runtime)
    project.path(to: path)
  end

  # private

  # TODO: Move these methods out or remove them
  # def clean_cache
  #   # NOTE: Who calls this method?
  #   if application.selected_services.empty?
  #     FileUtils.rm_rf(path)
  #     return
  #   end

  #   context_service_names.each do |service_name|
  #     migration_file = "#{path}/#{service_name}-migrated"
  #     FileUtils.rm(migration_file) if File.exist?(migration_file)
  #     FileUtils.rm(credentials[:local_file]) if service_name.eql?('iam') && File.exist?(credentials[:local_file])
  #   end
  # end

  # def credentials
  #   { remote_file: '/home/rails/services/app/tmp/mounted/credentials.json',
  #     local_file: "#{path}/target/credentials.json",
  #     local_path: "#{path}/target" }
  # end

  # def self.create_table(schema)
  def self.add_columns(t)
    # schema.create_table :runtimes, force: true do |t|
      # t.string :_source
      # t.references :project
      # t.string :name
      # t.string :config
      t.string :dependencies
      t.string :environment
      t.string :type
      t.string :tags
    # end
  end
end
