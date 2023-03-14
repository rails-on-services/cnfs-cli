# frozen_string_literal: true

module SolidRecord
  class Segment < ActiveRecord::Base
    self.table_name_prefix = 'solid_record_'
    include Table
    include TreeView

    # Segments are self referencing; They belong to a parent segment and have_many child segments
    belongs_to :parent, class_name: 'SolidRecord::Segment'
    has_many :segments, foreign_key: 'parent_id'

    # root is the first element created by the user; It is at the top of the hierarchy and stores user supplied values
    belongs_to :root, class_name: 'SolidRecord::Segment'

    # Owner of the model (optional), e.g. the model's belongs_to object
    belongs_to :owner, polymorphic: true

    store :config, accessors: %i[model_class_name]

    serialize :flags, Set

    scope :flagged, -> { where.not(flags: nil) }

    scope :flagged_for, lambda { |flag = nil|
      flag ? where('flags LIKE ?', "%#{flag}%") : where({})
    }

    # TODO: Wrap in begin/rescue
    def create_segment(klass, hash)
      segment = klass.create(create_hash.merge(hash))
      if segment.valid?
        segments << segment
      else
        error_msg = segment.errors.full_messages.append(segment.to_json).join("\n").to_s
        SolidRecord.raise_or_warn(StandardError.new(error_msg))
      end
    end

    # The default values assigned to a new segment
    def create_hash = { parent: self, root: root, owner: owner }

    def owner_assn(type = :has_many) = association_names(owner.class, type)

    def association_names(klass, type) = klass.reflect_on_all_associations(type).map(&:name).map(&:to_s)

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
