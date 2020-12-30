# frozen_string_literal: true

module Concerns
  module BelongsToProject
    extend ActiveSupport::Concern

    included do
      belongs_to :project

      # For records created with new during cli operations
      after_initialize do
        self.project ||= Cnfs.project if new_record?
      end

      delegate :options, :paths, :write_path, to: :project
    end
  end
end
