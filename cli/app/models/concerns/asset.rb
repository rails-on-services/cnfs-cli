# frozen_string_literal: true

module Concerns
  module Asset
    extend ActiveSupport::Concern

    included do
      include Concerns::Encryption
      # include Concerns::Interpolation

      has_one :parent, as: :owner, class_name: 'Node'
      belongs_to :owner, polymorphic: true, required: true

      scope :inheritable, -> { where(inherit: [true, nil]).order(:id) }
      scope :enabled, -> { where(enable: [true, nil]) }

      store :config, coder: YAML

      delegate :key, to: :owner

      validates :name, presence: true

      # TODO:
      # Put this code and methods into a concern and include in Component and Asset
      # The type string will need to come from the Component and Asset Concern
      after_create :create_node
      after_update :update_node
    end

    def create_node
      # Assets whose owner is Context are ephemeral so don't create/update a node
      return unless owner.is_a? Component
      # binding.pry

      create_parent(type: 'Node::Asset', owner: self)

      # From Component:
      # create_parent(type: 'Node::ComponentDir', path: name, owner: self, parent: owner.parent)
    end

    def update_node
      # Assets whose owner is Context are ephemeral so don't create/update a node
      return unless owner.is_a? Component
      # binding.pry

      parent.update(owner: self)
    end

    def tree_name
      %w[inherit enable].each_with_object([name]) do |v, ary|
        ary.append("(#{v})") if v.nil? || v
      end.join(' ')
    end

    class_methods do
      def node_callbacks
        [
          %i[create after create_node],
          %i[update after update_node],
        ]
      end

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
