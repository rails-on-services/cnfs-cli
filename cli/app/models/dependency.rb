# frozen_string_literal: true

class Dependency < ApplicationRecord
  include Concerns::BelongsToProject

  parse_sources :cli, :project

  def self.create_table(schema)
    schema.create_table :dependencies, force: true do |t|
      t.references :project
      t.string :name
      t.string :linux
      t.string :mac
      t.string :tags
    end
  end
end
