# frozen_string_literal: true

class PostProcessor < ApplicationRecord
  belongs_to :build

  parse_sources :project

  def as_save
    attributes.except('id', 'name', 'builder_id')
              .merge(build: build&.name)
  end

  def as_packer
    super.merge(output: "post-processors/#{packer_name}/output/#{packer_name}.box")
  end

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
