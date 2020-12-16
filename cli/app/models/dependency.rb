# frozen_string_literal: true

class Dependency < ApplicationRecord
  include BelongsToProject

  parse_sources :cli, :project

  def self.create_table(s)
    s.create_table :dependencies, force: true do |t|
      t.references :project
      t.string :name
      t.string :linux
      t.string :mac
      t.string :tags
     end
  end
end
