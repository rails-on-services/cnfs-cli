# frozen_string_literal: true

class Provisioner < ApplicationRecord
  include Concerns::BelongsToBuild

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :build
        t.string :name
        t.string :config
        t.integer :order
        t.string :type
      end
    end
  end
end
