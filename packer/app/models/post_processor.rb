# frozen_string_literal: true

class PostProcessor < ApplicationRecord
  include Concerns::BelongsToBuild

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :build
        t.string :config
        t.string :name
        t.integer :order
        t.string :type
      end
    end
  end
end
