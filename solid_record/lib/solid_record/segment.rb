# frozen_string_literal: true

module SolidRecord
  class Segment < ActiveRecord::Base
    include Table
    include TreeView
    self.table_name_prefix = 'solid_record_'

    # Values are passed in from Document and Association to Elements and passed on to model_class.create
    attr_accessor :values

    store :config, accessors: %i[model_class_name]

    # Segments are self referencing; They belong to a parent element and have_many child elements
    belongs_to :parent, class_name: 'SolidRecord::Segment'
    has_many :segments, foreign_key: 'parent_id'

    # Owner of the model (optional), e.g. the model's belongs_to object
    belongs_to :owner, polymorphic: true

    # def owner_assn(type = :has_many) = owner.class.reflect_on_all_associations(type).map(&:name).map(&:to_s)
    def owner_assn(type = :has_many) = association_names(owner.class, type)
    def model_assn(type = :has_many) = association_names(model.class, type)

    def association_names(klass, type) = klass.reflect_on_all_associations(type).map(&:name).map(&:to_s)

    scope :flagged, -> { where.not(flags: nil) }

    scope :flagged_for, lambda { |flag = nil|
      flag ? where('flags LIKE ?', "%#{flag}%") : where({})
    }

    serialize :flags, Set

    def src() = parent.nil? ? self : parent.src

    delegate :document, to: :parent, allow_nil: true # Ascend the element tree until hitting a Document

    # The class of the model managed (created, updated, destroyed) by an instance of Element
    def model_class
      @model_class ||= retc(model_class_name) || retc(src.namespace, model_class_name) ||
         SolidRecord.raise_or_warn(StandardError.new(self.to_json))
    end

    def retc(*ary) = ary.compact.join('/').classify.safe_constantize 

    # NOTE: Implement TreeView by defining #tree_assn and tree_label
    def tree_assn() = :segments

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
