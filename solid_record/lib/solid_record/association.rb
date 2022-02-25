# frozen_string_literal: true

module SolidRecord
  # An AssociationElement represents as `has_many` association on a model
  # The values attribute may contain an Array of model values or Hash of model values
  # In either case the values represent a result set and not a single instance
  class Association < Element
    store :config, accessors: %i[serializer name]

    validates :model_type, presence: true

    before_create :identify_serializer

    after_create :create_model_elements

    def identify_serializer() = self.serializer ||= values.class.to_s.underscore

    def create_model_elements() = send("create_from_#{serializer}".to_sym)

    def create_from_array
      values.each { |model_values| create_model_element(model_values[model_class.key_column], model_values) }
    end

    def create_from_hash() = values.each { |model_key, model_values| create_model_element(model_key, model_values) }

    def create_model_element(model_key, model_values)
      elements.create(type: element_type, model_type: model_type, key: model_key, values: model_values, owner: owner)
    end

    def to_solid(flag = nil) = send("to_solid_#{serializer}", flag)

    def to_solid_array(flag = nil) = elements.flagged_for(flag).map(&:to_solid)

    def to_solid_hash(flag = nil)
      elements.flagged_for(flag).each_with_object({}) { |e, hash| hash.merge!(e.to_solid_hash) }
    end

    def element_type() = 'SolidRecord::ModelElement'

    def tree_label() = "#{name} (#{type.demodulize} - #{serializer})"
  end
end
