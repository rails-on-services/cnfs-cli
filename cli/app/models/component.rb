# frozen_string_literal: true

class Component < ApplicationRecord
  belongs_to :owner, class_name: 'Component'
  belongs_to :context
  has_one :parent, as: :asset, class_name: 'Node'

  has_many :components, foreign_key: 'owner_id'

  # Pluralized resource names are declared as a has_many
  Cnfs.config.asset_names.select{ |name| name.pluralize.eql?(name) }.each do |asset_name|
    has_many asset_name.to_sym, as: :owner
  end

  class << self
    def child_component_class
      binding.pry
      if (idx = Cnfs.config.orders.index(table_name))
        # puts table_name
        # binding.pry
        Cnfs.config.order[idx + 1].classify
      else
        # binding.pry
      end
    end

    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :owner
        t.references :context
        t.string :name
        t.string :config
        t.string :type
      end
    end
  end
end
