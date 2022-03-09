# frozen_string_literal: true

module SolidRecord
  class << self
    # The name of including model's has_one reference to the SolidRecord::Element instance
    # that manges the model's persistence data
    def element_attribute() = 'element'

    # Array of models that have included the SolidRecord::Persistence concern
    def persisted_models() = @persisted_models ||= []

    def skip_persistence_callbacks
      persisted_models.each { |model| model.skip_callback(*persistence_callbacks) }
      ret_val = yield
    rescue StandardError => e
      SolidRecord.raise_or_warn(e)
    ensure
      persisted_models.each { |model| model.set_callback(*persistence_callbacks) }
      ret_val
    end

    def persistence_callbacks() = %i[create after __create_element]
  end

  module Persistence
    extend ActiveSupport::Concern

    class_methods do
      # The name of the table column that the yaml key is written to in the model
      def key_column() = 'key'

      def owner_association_name() = nil

      def except_solid
        reflect_on_all_associations(:belongs_to).each_with_object([primary_key]) do |a, ary|
          ary.append(a.options[:foreign_key] || "#{a.name}_id")
        end
      end

      def belongs_to_names() = reflect_on_all_associations(:belongs_to).map(&:name)
    end

    included do
      has_one SolidRecord.element_attribute.to_sym, class_name: 'SolidRecord::Element', as: :model

      delegate :__update_element, :__destroy_element, to: SolidRecord.element_attribute.to_sym
      delegate :belongs_to_names, :except_solid, to: :class

      after_create :__create_element
      after_update :__update_element
      after_destroy :__destroy_element

      SolidRecord.persisted_models << self
    end

    def __create_element
      if belongs_to_names.size.eql?(1) # rubocop:disable Style/GuardClause
        owner = send(belongs_to_names.first)
        owner.element.add_model(self)
      end
    end

    def as_solid() = attributes.except(*except_solid)
  end
end
