# frozen_string_literal: true

class User < ApplicationRecord
  # include Concerns::BelongsToProject
  include Concerns::Taggable

  belongs_to :owner, polymorphic: true
  # parse_sources :project, :user

  def as_save
    attributes.except('id') # , 'project_id')
  end

  class << self
    def create_table(schema)
      schema.create_table :users, force: true do |t|
        t.references :owner, polymorphic: true
        t.string :_source
        t.string :name
        t.string :role
        t.string :tags
      end
    end
  end
end
