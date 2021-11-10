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
      # binding.pry
      parent.update(owner: self, skip_owner_create: true)
    end

    class_methods do
      def update_names
        reference_columns.group_by { |n| n.split('_').first }.select { |_k, v| v.size.eql?(2) }.keys
      end

      def update_nils
        reference_columns.group_by { |n| n.split('_').first }.select { |_k, v| v.size.eql?(2) }.keys
      end

      def reference_columns
        @reference_columns ||= column_names.select { |n| n.end_with?('_id') || n.end_with?('_name') }
      end

      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.references :owner, polymorphic: true
          t.string :name
          t.string :config
          t.string :type
          t.boolean :enable
          t.boolean :inherit
          add_columns(t) if respond_to?(:add_columns)
        end
      end
    end
  end
end
