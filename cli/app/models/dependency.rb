# frozen_string_literal: true

class Dependency < ApplicationRecord
  include Concerns::Asset

  def self.add_columns(t)
    # schema.create_table :dependencies, force: true do |t|
      t.references :project
      # t.string :name
      t.string :linux
      t.string :mac
      t.string :tags
    # end
  end
end
