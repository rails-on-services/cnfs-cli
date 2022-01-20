# frozen_string_literal: true

module SolidRecord
  class << self
    def reference_suffix() = 'name'
  end

  class Element < ActiveRecord::Base
    include SolidRecord::Table
    self.table_name_prefix = 'solid_record_'

    # klass is the model's class
    # key is the ID used to reference the model
    # values is the payload hash passed to klass.create
    # owner is the optional owner of the model, e.g. the model's belongs_to object
    attr_accessor :klass_type, :key, :values, :owner

    # Elements are self referencing; They belong to a parent element and have_many child elements
    belongs_to :parent, class_name: 'SolidRecord::Element'
    has_many :elements, foreign_key: 'parent_id'

    # Ascend the element tree until hitting the RootElement
    delegate :root, to: :parent

    # The Persistence Concern adds these methods to the model's callbacks
    # When a model's lifecycle event is triggred the root element will handle updating the underlying document
    delegate :__create_asset, :__update_asset, :__destroy_asset, to: :root

    # The model instance of klass that is created from this element
    belongs_to :model, polymorphic: true

    before_create :create_model
    after_create :create_child_elements

    # Attempt to create an instance of klass and assign it to model
    def create_model
      # binding.pry # if model_values.nil?
      self.model = klass.create(model_values)
    rescue ActiveModel::UnknownAttributeError => e
      puts "Err: #{e.message}"
    end

    # The hash used to create the model
    # TODO: If owner is only coming from #create_child_elements then values.merge shoudl happen in that method
    def model_values
      vals = owner ? values.merge(owner.class.base_class.name.downcase => owner) : values
      vals.merge(associations).merge(solid_attributes).except(*has_many_names)
    end

    # Store the object's key in the table's user defined 'key_column'
    # And generate an ID based on the document path, object type and value of 'key_column'
    def solid_attributes() = { klass.key_column => key, 'id' => root.identify(key: key) }

    # Return a Hash of model_foreign_key_column => identified foreign key value
    # for each belongs_to association on the klass
    def associations
      belongs_to_assns.each_with_object({}) do |assn, hash|
        assn_name = assn.name.to_s # user
        hash_fk = "#{assn_name}_#{SolidRecord.reference_suffix}" # user_name
        # In a monolithic document the foreign key value is not required as it is part of the document hierarchy
        next unless (hash_fk_value = values[hash_fk])

        model_fk = assn.options[:foreign_key] || "#{assn_name}_id"
        # TODO: Maybe check and raise if not klass.column_names.include?(model_fk)
        assn_id = root.identify(key: hash_fk_value, type: assn_name.pluralize)
        hash[model_fk] = assn_id
      end
    end

    # If this element's payload includes associations then create elements for those
    def create_child_elements
      has_many_names.each do |assn_name|
        next unless (assn_hash = values[assn_name])

        assn_hash.each do |child_key, child_values|
          child_klass = assn_name.classify
          elements.create(klass_type: child_klass, key: child_key, values: child_values, owner: model)
        end
      end
    end

    # rubocop:disable Naming/PredicateName

    def has_many_names() = klass.reflect_on_all_associations(:has_many).map(&:name).map(&:to_s)
    # rubocop:enable Naming/PredicateName

    def belongs_to_assns() = klass.reflect_on_all_associations(:belongs_to)

    def klass() = @klass ||= klass_type.constantize

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.string :type
          t.references :parent
          t.references :document
          t.references :model, polymorphic: true
        end
      end
    end
  end

  # Specific Element type which represents a Document
  class RootElement < Element
    MAX_ID = (2**30) - 1

    belongs_to :document
    delegate :pathname, to: :document

    def root() = self

    # Returns an deterministic integer ID for a record based on path and key value representing an object
    def identify(key:, type: nil)
      type ||= pathname.name
      key_name = pathname.realpath.parent.join(type, key).to_s
      Zlib.crc32(key_name) % MAX_ID
      # debug("#{type}: #{key}", "from: #{pathname.realpath}", key_name, ret_val)
    end

    def __create_element
      # TODO: Determine where to write the element
      # binding.pry
    end

    def __update_element
      # TODO: call document.write
      # binding.pry
    end

    # def content_to_write() = pathname.singular? ? to_solid : pathname.read_asset.merge(to_solid)

    def __destroy_element
      # TODO: call document.write
      #   if pathname.singular? || pathname.read_asset.keys.size.eql?(1)
      #     pathname.delete
      #   else
      #     pathname.write_asset(pathname.read_asset.except(_key_))
      #   end
    end
  end
end
