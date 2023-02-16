# frozen_string_literal: true

module SolidRecord
  class Segment < ActiveRecord::Base
    include Table
    include TreeView
    self.table_name_prefix = 'solid_record_'

    # Segments are self referencing; They belong to a parent segment and have_many child segments
    belongs_to :parent, class_name: 'SolidRecord::Segment'
    belongs_to :root, class_name: 'SolidRecord::Segment'
    has_many :segments, foreign_key: 'parent_id'

    # def create_hash = { parent: self, root: root }
    def create_hash(**hash)
      { parent: self,
        root: root,
        owner: owner }.merge(hash)
    end

    # Owner of the model (optional), e.g. the model's belongs_to object
    belongs_to :owner, polymorphic: true

    store :config, accessors: %i[model_class_name]

    scope :flagged, -> { where.not(flags: nil) }

    scope :flagged_for, lambda { |flag = nil|
      flag ? where('flags LIKE ?', "%#{flag}%") : where({})
    }

    serialize :flags, Set

    # TODO: probably move this to Element and Association as only these two would refer to a document
    delegate :document, to: :parent, allow_nil: true # Ascend the element tree until hitting a Document

    # def owner_assn(type = :has_many) = owner.class.reflect_on_all_associations(type).map(&:name).map(&:to_s)
    def owner_assn(type = :has_many) = association_names(owner.class, type)

    def association_names(klass, type) = klass.reflect_on_all_associations(type).map(&:name).map(&:to_s)

    # def src() = parent.nil? ? self : parent.src

    # NOTE: Implement TreeView by defining #tree_assn and tree_label
    def tree_assn = :segments

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.string :type
          t.references :parent
          t.references :root
          t.references :owner, polymorphic: true
          t.references :model, polymorphic: true
          t.string :flags
          t.string :config
        end
      end
    end
  end
end
