# frozen_string_literal: true

module Concerns
  module Asset
    extend ActiveSupport::Concern

    included do
      include Concerns::Encryption
      # include Concerns::Interpolate

      attr_accessor :skip_node_create

      has_one :parent, as: :owner, class_name: 'Node'
      belongs_to :owner, polymorphic: true

      scope :inheritable, -> { where(inherit: [true, nil]).order(:id) }
      scope :enabled, -> { where(enable: [true, nil]) }

      store :config, coder: YAML

      delegate :key, to: :owner

      validates :name, presence: true

      after_create :create_node, unless: proc { skip_node_create }
      after_update :update_node, unless: proc { skip_node_create }
    end

    def create_node
      create_parent(type: 'Node::Asset', owner: self, skip_owner_create: true)
    end

    def update_node
      parent.update(owner: self, skip_owner_create: true)
    end

    class_methods do
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.references :owner, polymorphic: true
          t.string :name
          t.boolean :enable
          t.boolean :inherit
          t.string :type
          t.string :config
          add_columns(t) if respond_to?(:add_columns)
        end
      end
    end
  end
end
