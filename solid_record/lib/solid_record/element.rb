# frozen_string_literal: true

module SolidRecord
  class Element < ActiveRecord::Base
    include SolidRecord::Table
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

    # TODO: Move the TTY stuff to a controller and just return the hash
    def puts_tree(flagged: false) = puts(TTY::Tree.new(to_tree(flagged: flagged)).render)

    def to_tree(flagged: false) = { tree_label => as_tree(flagged) }

    def as_tree(flagged)
      filtered_elements = flagged ? elements.flagged : elements
      filtered_elements.each_with_object([]) do |element, ary|
        sub_filtered_elements = flagged ? element.elements.flagged : element.elements
        val = sub_filtered_elements.size.zero? ? element.tree_label : { element.tree_label => element.as_tree(flagged) }
        ary.append(val)
      end
    end

    class << self
      def create_from_path(path)
        path = Pathname.new(path)
        SolidRecord.raise_or_warn(StandardError.new("Invalid path #{path}")) unless path.exist?
        SolidRecord.skip_solid_record_callbacks { klass(path).create(path: path) }
      end

      def klass(path) = path.directory? ? SolidRecord::Path : SolidRecord::Document

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
