# frozen_string_literal: true

class Builder < ApplicationRecord
  include Concerns::BelongsToBuild

  # The source for a builder may be the output of the previous
  # pipeline's builder or post_processor
  belongs_to :builder
  # belongs_to :post_processor

  # def set_defaults; end

  def as_save
    attributes.except('id', 'build_id', 'builder_id').merge(builder: builder&.name)
  end

  def as_packer
    super.except(:operating_system_id, :builder_id)
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :build
        t.references :builder
        # NOTE: operating_system is not valid for all builders
        t.references :operating_system
        # t.references :post_processor
        t.string :config
        t.string :name
        t.integer :order
        t.string :type
      end
    end
  end
end
