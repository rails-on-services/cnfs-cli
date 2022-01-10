# frozen_string_literal: true

class Context < ApplicationRecord
  belongs_to :component

  has_many :context_components
  has_many :components, through: :context_components

  Cnfs::Core.asset_names.each do |asset_name|
    # component_<asset> = all <assets> from the component hierarchy
    has_many "component_#{asset_name}".to_sym, through: :components, source: asset_name.to_sym
    has_many asset_name.to_sym, as: :owner
  end

  store :options, coder: YAML

  # When decrypting values assets ask for the key from their owner
  # When context is the owner it must ask the component for the key
  # TODO: The assets need to be decrypted with reference to their actual owner not the context.component
  # This will not work for inherited values. This needs to be tested
  delegate :attrs, :cache_path, :data_path, :key, :as_interpolated, :segments_type, :segment_names, :as_tree,
           to: :component

  after_create :create_assets
  after_commit :update_asset_associations

  def create_assets
    Node.with_asset_callbacks_disabled do
      Cnfs::Core.asset_names.each do |asset_type|
        component_assets = component.send(asset_type.to_sym)
        inheritable_assets = send("component_#{asset_type}".to_sym).inheritable
        context_assets = send(asset_type.to_sym)
        first_pass(component_assets, inheritable_assets, context_assets)
        second_pass(component_assets, inheritable_assets, context_assets)
      end
    end
  end

  def first_pass(component_assets, inheritable_assets, context_assets)
    component_assets.enabled.each do |asset|
      # binding.pry if asset.class.name.eql? 'Plan'
      name = asset.name
      json = inheritable_assets.where(name: name).each_with_object({}) do |record, hash|
        hash.deep_merge!(record.to_context.compact)
      end
      json.deep_merge!(asset.to_context.compact)
      context_assets.create(json.merge(name: name))
    end
  end

  # Inheritable assets that are not defined in the component, but are enabled are added to the context
  # All values of the inherited assets of the same name are deep merged
  def second_pass(component_assets, inheritable_assets, context_assets)
    names = component_assets.pluck(:name)
    # binding.pry if inheritable_assets.any? and inheritable_assets.first.class.name.eql?('Plan')
    inheritable_assets.enabled.where.not(name: names).group_by(&:name).each_with_object([]) do |(name, records), _ary|
      json = records.each_with_object({}) do |record, hash|
        hash.deep_merge!(record.to_context.compact)
      end
      context_assets.create(json.merge(name: name)) # unless json['disabled']
    end
  end

  def update_asset_associations
    Cnfs::Core.asset_names.each { |asset_type| asset_type.classify.constantize.update_associations(self) }
  end

  # Used by runtime generator templates so the runtime can query services by label
  def labels() = @labels ||= labels_hash

  def labels_hash
    # TODO: Refactor; maybe to Component class
    component_structs.each_with_object({ 'context' => name }) do |component, hash|
      hash[component.segment_type] = component.name
    end
  end

  def name() = @name ||= attrs.join('_')

  def path() = @path ||= attrs.join('/')

  def options() = @options ||= Thor::CoreExt::HashWithIndifferentAccess.new(super)

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :component
        t.string :options
      end
    end
  end
end
