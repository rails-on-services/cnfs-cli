# frozen_string_literal: true

module BelongsToProject
  extend ActiveSupport::Concern

  included do
    belongs_to :project

    # For records created with new during cli operations
    after_initialize do
      self.project ||= Cnfs.project
    end

    delegate :options, :paths, :write_path, to: :project
  end

  # NOTE: the including class must implement #save_hash
  def save
    o = Config.load_file(file_path)
    o.merge!(save_hash)
    o.save
  end

  def delete
    o = Config.load_file(file_path)
    # TODO: raise
    return if o.key?(name)

    o.delete_field(name)
    o.save
    on_delete if respond_to?(:on_delete)
    super
  end

  def file_path
    paths.config.join("#{self.class.table_name}.yml")
  end
end
