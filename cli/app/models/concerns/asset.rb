# frozen_string_literal: true

module Concerns
  module Asset
    extend ActiveSupport::Concern

    included do
      has_one :parent, as: :asset, class_name: 'Node'
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
          t.references :owner, polymorphic: true
          t.string :name
          t.string :config
          t.boolean :abstract
          add_columns(t)
        end
      end
    end
  end
end
