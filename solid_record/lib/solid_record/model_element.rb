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

    delegate :key_column, to: :model_class

    before_create :create_model
    after_create :create_associations

    # The created model's string key in the table's user defined 'key_column'
    def model_key() = model.send(key_column)

    # Create an instance of model_class and assign it to the model attribute
    def create_model
      self.model = model_class.create(model_values)
      raise ModelSaveError, "Err #{model_class}: #{model.errors.full_messages.join('. ')}" unless model.persisted?
    rescue ModelSaveError, ActiveModel::UnknownAttributeError, ActiveRecord::SubclassNotFound => e
      SolidRecord.raise_or_warn(e, "#{model_class} #{e.message}")
    end

    # @return [Hash] Merge the original values with owner and any belongs_to calculated IDs
    def model_values
      values.except(*assn_names).merge(belongs_to_attributes).merge(owner_attribute).merge(key_column => key)
    end

    def owner_attribute() = owner ? { owner.class.base_class.name.downcase => owner } : {}

    # For each belongs_to association on the model_class
    # @return [Hash] of model_foreign_key_column => identified foreign key value
    def belongs_to_attributes
      model_class.reflect_on_all_associations(:belongs_to).each_with_object({}) do |assn, _hash|
        hash_fk = "#{assn.name}_#{SolidRecord.reference_suffix}" # user_name
        # In a monolithic document the foreign key value is not part of the document hierarchy so it will be nil
        next unless (_hash_fk_value = values[hash_fk])

        # model_fk = assn.options[:foreign_key] || "#{assn.name}_id"
        # TODO: Maybe check and raise if not model_class.column_names.include?(model_fk)
        raise 'TODO: This will be a bug'
        # assn_id = root.identify(key: hash_fk_value, type: assn.name.to_s.pluralize)
        # hash[model_fk] = assn_id
      end
    end

    # If this element's payload includes associations then create elements for those
    def create_associations
      assn_names.each do |assn_name|
        next unless (assn_values = values[assn_name])

        elements.create(type: 'SolidRecord::Association', name: assn_name,
                        model_type: assn_name.classify, values: assn_values, owner: model)
      end
    end

    def assn_names() = model_class.reflect_on_all_associations(:has_many).map { |a| a.name.to_s }

    # The Persistence Concern adds these lifecycle methods to the model's callback chains
    # When a model's lifecycle event is triggred it invokes its element's method of the same name
    # def __create_element() = parent.create_element(to_solid)

    def __update_element() = document.flag(:update)

    def __destroy_element
      update(flags: flags << :destroy)
      document.flag(:update)
    end

    def to_solid_hash() = { model_key => to_solid.except(key_column) }

    def to_solid() = solid_elements.each_with_object(as_solid) { |e, hash| hash[e.name] = e.to_solid }

    def as_solid() = model.as_solid.compact.sort.to_h

    def solid_elements() = elements.where.not(type: 'SolidRecord::Path')

    def tree_label() = "#{model_key} (#{type.demodulize})"
  end
end
