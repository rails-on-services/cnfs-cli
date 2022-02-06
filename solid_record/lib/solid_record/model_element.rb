# frozen_string_literal: true

module SolidRecord
  class << self
    def reference_suffix() = 'name'
  end

  class ModelSaveError < Error; end

  class ModelElement < Element
    # TODO: Note where each of these attributes originate from
    # The ID used to reference the model
    attr_accessor :key

    # The model instance of model_class that is created from this element
    belongs_to :model, polymorphic: true

    before_create :create_model

    after_create :create_associations

    delegate :key_column, to: :model_class

    # The created model's string key in the table's user defined 'key_column'
    def model_name() = model.send(key_column)

    # Create an instance of model_class and assign it to the model attribute
    def create_model
      self.model = model_class.create(model_values)
      raise ModelSaveError, "Err #{model_class}: #{model.errors.full_messages.join('. ')}" unless model.persisted?
    rescue ModelSaveError, ActiveModel::UnknownAttributeError, ActiveRecord::SubclassNotFound => e
      SolidRecord.raise_or_warn(e, "#{model_class} #{e.message}")
    end

    # @return [Hash] Merge the original values with owner and any belongs_to calculated IDs
    def model_values
      model_vals = owner ? values.merge(owner_attribute) : values
      model_vals.merge(belongs_to_attributes).merge(key_column => key).except(*has_many_names)
    end

    def owner_attribute() = { owner.class.base_class.name.downcase => owner }

    # rubocop:disable Metrics/AbcSize

    # For each belongs_to association on the model_class
    # @return [Hash] of model_foreign_key_column => identified foreign key value
    def belongs_to_attributes
      model_class.reflect_on_all_associations(:belongs_to).each_with_object({}) do |assn, hash|
        hash_fk = "#{assn.name}_#{SolidRecord.reference_suffix}" # user_name
        # In a monolithic document the foreign key value is not part of the document hierarchy so it will be nil
        next unless (hash_fk_value = values[hash_fk])

        model_fk = assn.options[:foreign_key] || "#{assn.name}_id"
        # TODO: Maybe check and raise if not model_class.column_names.include?(model_fk)
        # TODO: This will be a bug
        assn_id = root.identify(key: hash_fk_value, type: assn.name.to_s.pluralize)
        hash[model_fk] = assn_id
      end
    end
    # rubocop:enable Metrics/AbcSize

    # If this element's payload includes associations then create elements for those
    def create_associations
      has_many_names.each do |assn_name|
        next unless (assn_values = values[assn_name])

        elements.create(type: 'SolidRecord::Association', name: assn_name,
                        model_type: assn_name.classify, values: assn_values, owner: model)
      end
    end

    def has_many_names() = model_class.reflect_on_all_associations(:has_many).map(&:name).map(&:to_s) # rubocop:disable Naming/PredicateName

    # The Persistence Concern adds these methods to the model's callbacks
    # When a model's lifecycle event is triggred pass model#to_solid up the parent hierarchy until
    # it reaches the root element which will pass the full hash to the underlying document

    # def :__destroy_element() = blah # This should destroy the current element and cascade deletes across elements
    # then it should go to the parent and have it write it out so that all child elements are destroyed
    # documents and paths should be removed from the file system

    # def __create_element() = parent.create_element(to_solid)

    def __update_element() = root.update_document

    def to_solid
      model_hash = parent.serializer.eql?('array') ? as_solid : { model_name => as_solid.except(key_column) }
      selected_elements.each_with_object(model_hash) { |element, hash| hash[element.name] = element.to_solid }
    end

    def as_solid() = model.as_solid.compact.sort.to_h

    # Paths create other Documents which should never be included when updating the current document
    def selected_elements() = elements.reject { |e| e.type.eql?('SolidRecord::Path') }

    def tree_label() = model_class.sti_column ? "#{model_name} (#{model.send(model_class.sti_column)})" : model_name
  end
end
