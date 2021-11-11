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

      # TODO:
      # Put this code and methods into a concern and include in Component and Asset
      # The type string will need to come from the Component and Asset Concern
      # Rename from skip_node_create to notify_node
      # Rather than passing skip_owner_create to the Node
      # havekk
      # with_options unless: :skip_node_create do |asset|
      #   asset.after_create :create_node
      #   asset.after_update :update_node
      # end

      after_create :create_node, unless: proc { skip_node_create }
      after_update :update_node, unless: proc { skip_node_create }
    end

    def tree_name
      %w[inhert enable].each_with_object([name]) do |v, ary|
        ary.append("(#{v})") if v.nil? || v
      end.join(' ')
    end

    def create_node
      # return unless owner.is_a? Component
      create_parent(type: 'Node::Asset', owner: self, skip_owner_create: true)
    end

    def update_node
      # return unless owner.is_a? Component
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
