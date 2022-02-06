# frozen_string_literal: true

module SolidRecord
  class Element < ActiveRecord::Base
    include SolidRecord::Table
    self.table_name_prefix = 'solid_record_'

    # Values are passed in from Document and Assoication to ModelElements and passed on to model_class.create
    attr_accessor :values

    # Elements are self referencing; They belong to a parent element and have_many child elements
    belongs_to :parent, class_name: 'SolidRecord::Element'
    has_many :elements, foreign_key: 'parent_id'

    # Owner of the model (optional), e.g. the model's belongs_to object
    belongs_to :owner, polymorphic: true

    # Ascend the element tree until hitting a RootElement. used by ModelElement and Association
    delegate :root, to: :parent

    store :config, coder: YAML

    # The class of the model managed (created, updated, destroyed) by an instance of Element
    def model_class() = @model_class ||= model_type.constantize

    # TODO: Move the TTY stuff to a controller and just return the hash
    def to_tree() = puts(TTY::Tree.new({ tree_label => as_tree }).render)
    # def to_tree() = TTY::Tree.new({ tree_label => as_tree }).render
    # def to_tree() = { tree_label => as_tree }

    def as_tree
      elements.each_with_object([]) do |element, ary|
        value = element.elements.size.zero? ? element.tree_label : { element.tree_label => element.as_tree }
        ary.append(value)
      end
    end

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.string :type
          t.references :parent
          t.references :owner, polymorphic: true
          t.references :model, polymorphic: true
          t.string :config
        end
      end
    end
  end
end
