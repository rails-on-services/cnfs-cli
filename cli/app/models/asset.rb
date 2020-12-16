# frozen_string_literal: true

class Asset < ApplicationRecord
  belongs_to :owner, polymorphic: true

  def self.create_table(s)
    s.create_table :assets, force: true do |t|
      t.string :name
      t.string :type
      t.string :path
      t.string :owner_type
      t.string :owner_id
      t.string :tags
    end
  end
end
