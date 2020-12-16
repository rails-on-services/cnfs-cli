# frozen_string_literal: true

class User < ApplicationRecord
  include BelongsToProject
  include Taggable

  parse_sources :project, :user

  def as_save
    attributes.except('id', 'project_id')
  end

  class << self
    def create_table(s)
      s.create_table :users, force: true do |t|
        t.references :project
        t.string :name
        t.string :role
        t.string :tags
      end
    end
  end
end
