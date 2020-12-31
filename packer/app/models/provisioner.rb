# frozen_string_literal: true

class Provisioner < ApplicationRecord
  belongs_to :build

  parse_sources :project
  parse_scopes :build

  def as_save
    attributes.except('id', 'name', 'builder_id').merge(build: build&.name)
  end

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
