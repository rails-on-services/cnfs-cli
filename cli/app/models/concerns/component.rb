# frozen_string_literal: true

module Concerns
  module Component
    extend ActiveSupport::Concern

    included do
      belongs_to :parent, class_name: 'Node'

      if (idx = Cnfs.config.orders.index(table_name))
        belongs_to Cnfs.config.order[idx - 1].to_sym if idx.positive?
        Cnfs.config.orders.each_index do |i|
          next if i <= idx

          association = Cnfs.config.orders[i].to_sym
          has_many association if i == idx + 1
          next if i == idx + 1

          has_many association, through: Cnfs.config.orders[i - 1].to_sym
          break if i == Cnfs.config.orders.size - 1
        end
      end

      has_many :services, as: :owner
      has_many :resources, as: :owner

      store :config, coder: YAML

      validates :name, presence: true
    end

    class_methods do
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.references :parent
          if (idx = Cnfs.config.orders.index(table_name))
            t.references Cnfs.config.order[idx - 1] if idx.positive?
          end
          t.string :name
          t.string :config
          add_columns(t)
        end
      end
    end
  end
end
