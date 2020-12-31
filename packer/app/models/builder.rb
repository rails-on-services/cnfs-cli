# frozen_string_literal: true

class Builder < ApplicationRecord
  belongs_to :build

  delegate :project, to: :build

  parse_sources :project
  parse_scopes :build

  def as_save
    attributes.except('id', 'name', 'builder_id').merge(build: build&.name)
  end

  def as_packer
    super.except(:operating_system_id)
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :build
        t.references :operating_system
        t.string :config
        t.string :name
        t.integer :order
        t.string :type
      end
    end
  end
end
