# frozen_string_literal: true

class NodeAsset < ApplicationRecord
  belongs_to :node
  belongs_to :asset, polymorphic: true

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :node
        t.references :asset, polymorphic: true
      end
    end
  end
end
