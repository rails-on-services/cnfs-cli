# frozen_string_literal: true

module SolidRecord
  class << self
    def element_key() = 'element'
    # attr_writer :path_column, :key_column, :reference_suffix

    # Default values for SolidRecord that are used in the Persistence Concern
    # def path_column() = @path_column ||= 'path'

    # def reference_suffix() = @reference_suffix ||= 'name'

    def persisted_models() = @persisted_models ||= []

    def skip_model_callbacks
      persisted_models.each { |model| model.skip_callback(*model_callbacks) }
      yield
      persisted_models.each { |model| model.set_callback(*model_callbacks) }
    end

    def model_callbacks() = %i[create after __create_element]
  end

  module Persistence
    extend ActiveSupport::Concern

    class_methods do
      def key_column() = 'key'
    end

    included do
      has_one SolidRecord.element_key.to_sym, class_name: 'SolidRecord::Element', as: :model

      # Model lifecyle methods are delegated to RootElement
      delegate :__create_element, :__update_element, :__destroy_element, to: SolidRecord.element_key.to_sym

      after_create :__create_element
      after_update :__update_element
      after_destroy :__destroy_element

      SolidRecord.persisted_models << self
    end

    def to_solid() = { send(self.class.key_column) => as_solid }

    def as_solid() = as_json.except(*except_solid)

    def except_solid() = ['id', self.class.key_column]
  end
end
