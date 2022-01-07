# frozen_string_literal: true

class ContextComponent < ApplicationRecord
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
