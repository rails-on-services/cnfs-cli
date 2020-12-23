# frozen_string_literal: true

class Registry < ApplicationRecord
  def self.create_table(schema)
    schema.create_table :registries, force: true do |t|
      t.string :name
      t.string :config
      t.string :type
    end
  end
end
