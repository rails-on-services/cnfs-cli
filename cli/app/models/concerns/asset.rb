# frozen_string_literal: true

module Concerns
  module Asset
    extend ActiveSupport::Concern

    included do
      include Concerns::Key

      attr_accessor :skip_node_create

      has_one :parent, as: :owner, class_name: 'Node'
      belongs_to :owner, polymorphic: true

      scope :inheritable, -> { where(inherit: true).order(:id) }
      scope :enabled, -> { where(disabled: [false, nil]) }

      store :config, coder: YAML

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
          t.string :config
          t.boolean :inherit
          t.boolean :disabled
          add_columns(t)
        end
      end
    end
  end
end
