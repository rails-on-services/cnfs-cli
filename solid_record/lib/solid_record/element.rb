# frozen_string_literal: true

module SolidRecord
  class Element < ActiveRecord::Base
    include SolidRecord::Table
    include SolidSupport::TreeView
    self.table_name_prefix = 'solid_record_'

    # Values are passed in from Document and Association to ModelElements and passed on to model_class.create
    attr_accessor :values

    # Elements are self referencing; They belong to a parent element and have_many child elements
    belongs_to :parent, class_name: 'SolidRecord::Element'
    has_many :elements, foreign_key: 'parent_id'

    # Owner of the model (optional), e.g. the model's belongs_to object
    belongs_to :owner, polymorphic: true

    scope :flagged, -> { where.not(flags: nil) }

    scope :flagged_for, lambda { |flag = nil|
      flag ? where('flags LIKE ?', "%#{flag}%") : where({})
    }

    serialize :flags, Set

    delegate :document, to: :parent, allow_nil: true # Ascend the element tree until hitting a Document

    # The class of the model managed (created, updated, destroyed) by an instance of Element
    def model_class() = @model_class ||= model_type.constantize

    # NOTE: Implement TreeView by defining #tree_assn and tree_label
    def tree_assn() = :elements

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.string :type
          t.references :parent
          t.references :owner, polymorphic: true
          t.references :model, polymorphic: true
          t.string :flags
          t.string :config
        end
      end
    end
  end
end
