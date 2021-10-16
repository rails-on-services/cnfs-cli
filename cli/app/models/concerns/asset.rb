# frozen_string_literal: true

module Concerns
  module Asset
    extend ActiveSupport::Concern

    included do
      belongs_to :parent, class_name: 'Node'
      belongs_to :owner, polymorphic: true

      store :config, coder: YAML

      validates :name, presence: true
      # For records created with new during cli operations
      # after_initialize do
      #   self.project ||= Cnfs.project if new_record?
      # end

      # delegate :options, :paths, :write_path, to: :project
    end

    class_methods do
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.references :parent
          t.references :owner, polymorphic: true
          t.string :name
          t.string :config
          add_columns(t)
        end
      end
    end
  end
end
