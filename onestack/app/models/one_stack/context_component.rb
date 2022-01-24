# frozen_string_literal: true

module OneStack
class ContextComponent < ApplicationRecord
  include SolidRecord::Table

  belongs_to :context
  belongs_to :component

  validates :component_id, uniqueness: { scope: :context_id }

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :context
        t.references :component
      end
    end
  end
end
end
