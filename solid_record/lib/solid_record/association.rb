# frozen_string_literal: true

module SolidRecord
  # An AssociationElement represents as `has_many` association on a model
  # The values attribute may contain an Array of model values or Hash of model values
  # In either case the values represent a result set and not a single instance
  class Association < Segment
    attr_accessor :values

    store :config, accessors: %i[name serializer]

    validates :model_class_name, presence: true

    before_create :identify_serializer

    after_create :create_elements

    def identify_serializer = self.serializer ||= values.class.to_s.underscore

    def create_elements = send("create_from_#{serializer}".to_sym)

    # Dup
    def model_class
      @model_class ||= retc(model_class_name) || retc(namespace, model_class_name) ||
                       SolidRecord.raise_or_warn(StandardError.new(to_json))
    end
    # END: Dup

    def retc(*ary) = ary.compact.join('/').classify.safe_constantize

    def create_from_array
      values.each { |model_values| create_element(model_values[model_class.key_column], model_values) }
    end

    def create_from_hash = values.each { |model_key, model_values| create_element(model_key, model_values) }

    def create_element(model_key, model_values)
      segments << Element.create(create_hash(model_class_name: model_class_name, key: model_key,
                                             values: model_values, owner: owner))
    end

    def to_solid(flag = nil) = send("to_solid_#{serializer}", flag)

    def to_solid_array(flag = nil) = segments.flagged_for(flag).map(&:to_solid)

    def to_solid_hash(flag = nil)
      segments.flagged_for(flag).each_with_object({}) { |e, hash| hash.merge!(e.to_solid_hash) }
    end

    def tree_label = "#{name} (#{type.demodulize} - #{serializer})"

    # TODO: pathname is not just from a Dir; it is also constructed from
    # the association name
    delegate :pathname, to: :parent
  end
end
