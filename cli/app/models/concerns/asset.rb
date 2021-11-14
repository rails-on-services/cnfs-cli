# frozen_string_literal: true

module Concerns
  module Asset
    extend ActiveSupport::Concern

    included do
      include Concerns::Parent
      include Concerns::Encryption
      # include Concerns::Interpolation

      has_one :parent, as: :owner, class_name: 'Node'
      belongs_to :owner, polymorphic: true, required: true

      scope :inheritable, -> { where(inherit: [true, nil]).order(:id) }
      scope :enabled, -> { where(enable: [true, nil]) }

      delegate :key, to: :owner
    end

    def tree_name
      %w[inherit enable].each_with_object([name]) do |v, ary|
        ary.append("(#{v})") if v.nil? || v
      end.join(' ')
    end

    class_methods do
      def update_names
        belongs_to_names
      end

      def update_nils
        belongs_to_names
      end

      def belongs_to_names
        @belongs_to_names ||= reference_columns.group_by { |n| n.split('_').first }.select { |_k, v| v.size.eql?(2) }.keys
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
