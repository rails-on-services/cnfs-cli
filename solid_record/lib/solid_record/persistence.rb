# frozen_string_literal: true

module SolidRecord
  class << self
    # The name of including model's has_one reference to the SolidRecord::Element instance
    # that manges the model's persistence data
    def element_attribute() = 'element'

    # Array of models that have included the SolidRecord::Persistence concern
    def persisted_models() = @persisted_models ||= []

    def skip_solid_record_callbacks
      persisted_models.each { |model| model.skip_callback(*model_callbacks) }
      ret_val = yield
    rescue StandardError => e
      SolidRecord.raise_or_warn(e)
    ensure
      persisted_models.each { |model| model.set_callback(*model_callbacks) }
      ret_val
    end

    def model_callbacks() = %i[create after __create_element]
  end

  module Persistence
    extend ActiveSupport::Concern

    class_methods do
      # The name of the table column that the yaml key is written to in the model
      def key_column() = 'key'

      def skip_solid_record_callbacks
        skip_callback(*SolidRecord.model_callbacks)
        ret_val = yield
      rescue StandardError => e
        SolidRecord.raise_or_warn(e)
      ensure
        set_callback(*SolidRecord.model_callbacks)
        ret_val
      end

      def except_solid
        reflect_on_all_associations(:belongs_to).map do |a|
          a.options[:foreign_key] || "#{a.name}_id"
        end.prepend(primary_key)
      end

      def include_solid() = column_names.include?(inheritance_column) ? [inheritance_column] : []
    end

    included do
      has_one SolidRecord.element_attribute.to_sym, class_name: 'SolidRecord::Element', as: :model

      # Model lifecyle methods are delegated to RootElement
      delegate :__create_element, :__update_element, :__destroy_element, to: SolidRecord.element_attribute.to_sym

      after_create :__create_element
      after_update :__update_element
      after_destroy :__destroy_element

      SolidRecord.persisted_models << self
    end

    def as_solid() = include_solid.each_with_object(attributes) { |att, h| h[att] = send(att) }.except(*exclude_solid)

    def include_solid() = self.class.include_solid

    def exclude_solid() = self.class.except_solid
  end
end
