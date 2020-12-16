# frozen_string_literal: true

module BelongsToProject
  extend ActiveSupport::Concern

  included do
    belongs_to :project

    # For records created with new during cli operations
    after_initialize do
      self.project ||= Cnfs.project if self.new_record?
    end

    delegate :options, :paths, :write_path, to: :project
  end
end
