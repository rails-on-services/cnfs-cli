# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Context < ApplicationRecord
  # Root is intended to be only a Project or Reppsitory (component not asset) as of now
  belongs_to :root, class_name: 'Component'
  belongs_to :component

  has_many :context_components
  has_many :components, through: :context_components

  # dynamic methods for all asset types:
  # component_<asset> All <assets> from the component hierarchy
  # <asset> All <assets> that are available given the value of abstract at each level
  # filtered_<asset> All available <assets> filterd by arguments provided by the cli
  # <asset>_runtime The runtime object for the <asset>

  CnfsCli.asset_names.each do |asset_name|
    has_many "component_#{asset_name}".to_sym, through: :components, source: asset_name.to_sym
    has_many asset_name.to_sym, as: :owner

    # For each asset there is a filtered_<asset_name> method that returns an A/R assn
    # with a where clause if any args were passed in
    define_method "filtered_#{asset_name}".to_sym do
      args_plural = args.send(asset_name)
      args_singular = args.send(asset_name.singularize)
      # TODO: This is probably a bug. If args_plural is empty then it should probably return
      # an empty array
      if args_plural&.any?
        send(asset_name).where(name: args_plural)
      elsif args_singular
        send(asset_name).where(name: args_singular)
      else
        send(asset_name)
      end
    end
  end

  store :options, coder: YAML
  store :args, coder: YAML

  # When decrypting values assets ask for the key from their owner
  # When context is the owner it must ask the component for the key
  delegate :key, :as_interpolated, to: :component

  # Add existing components to the context based on cli options, ENV and componet default values
  before_create :add_components, if: proc { root_id }
  after_create :create_assets, if: proc { root_id }
  after_commit :update_assets, if: proc { root_id }

  # Select the compoenents based on project and user supplied values
  # Update the component hierarchy tree
  # 1. Select from cli options
  # 2. Select from an ENV found in CNFS_component_name
  # 3. Select from a default set in project.yml
  #
  # The controller should call:
  # Context.create(root: Project.first, options: options)
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def add_components
    components << root
    current = root
    segment = nil
    while current.components.any?
      break unless (segment_spec  = segment_values(current)) # No serach values found so stop at the current component

      components << segment if segment
      # binding.pry
      if (segment = current.components.find_by(name: segment_spec.name))
        current = segment
        next
      end
      Cnfs.logger.warn("#{current.segment.capitalize} '#{segment_spec.name}' specified by  *#{segment_spec.source}* " \
                       "not found.\n#{' ' * 10}Context set to #{current.class.name} '#{current.name}'")
      break
    end
    self.component = segment || root # The last component found given the supplied options
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # Return a value for the current component's segment component based on priority
  # If a command line option was provided (e.g. -s stack_name) then return that value
  # If an ENV was provided (e.g. CNFS_STACK) then return that value
  # If the current component has an attribute 'default' then return that value
  # Otherwise return nil
  def segment_values(component)
    if (name = options.fetch(component.segment_type, nil))
      OpenStruct.new(name: name, source: 'CLI option')
    elsif (name = CnfsCli.config.segments[component.segment_type].try(:[], :env_value))
      OpenStruct.new(name: name, source: 'ENV value')
    elsif (name = component.segment_name)
      OpenStruct.new(name: name, source: component.parent.node_name)
    end
  end

  # TODO: Change the name of this method
  # TODO: What about tags?
  # @options.merge!('tags' => Hash[*options.tags.flatten]) if options.tags
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def create_assets
    Node.with_asset_callbacks_disabled do
      CnfsCli.asset_names.each do |asset_type|
        component_assets = component.send(asset_type.to_sym)
        parent_assets = send("component_#{asset_type}".to_sym)
        context_assets = send(asset_type.to_sym)
        enabled_assets(component_assets.enabled, parent_assets.inheritable).each do |json|
          context_assets.create(json)
        end
        inherited_assets(component_assets, parent_assets.inheritable).each do |json|
          context_assets.create(json)
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def enabled_assets(enabled_assets, inheritable_assets)
    enabled_assets.each_with_object([]) do |asset, ary|
      name = asset.name
      json = inheritable_assets.where(name: name).each_with_object({}) do |record, hash|
        hash.deep_merge!(record.as_merged.compact)
      end
      json.deep_merge!(asset.as_merged.compact)
      ary.append(json.merge(name: name))
    end
  end

  # Return an array of json objects for any inheritable assets that have not already
  # been specified by the context's component
  # All values of the inherited assets of the same name are deep merged and returned
  # if the resulting hash is not disabled
  def inherited_assets(component_assets, inheritable_assets)
    names = component_assets.pluck(:name)
    inheritable_assets.where.not(name: names).group_by(&:name).each_with_object([]) do |(name, records), ary|
      json = records.each_with_object({}) do |record, hash|
        hash.deep_merge!(record.as_merged.compact)
      end
      ary.append(json.merge(name: name)) unless json['disabled']
    end
  end

  def update_assets
    CnfsCli.asset_names.each do |asset_type|
      asset_type.classify.constantize.update_associations(self)
    end
  end

  # Returns an array of runtimes
  # TODO: This needs to be simplified OR much better well documented
  def resource_runtimes(services: filtered_services)
    services.where.not(resource: nil).group_by(&:resource).each_with_object([]) do |(resource, x_services), ary|
      runtime = resource.runtime
      runtime.context_services = x_services
      runtime.context = self
      ary.append(runtime)
    end
  end

  def blueprint_provisioners(resources: filtered_resources)
    resources.where.not(blueprint: nil).group_by(&:blueprint).each_with_object([]) do |(blueprint, x_resources), ary|
      provisioner = blueprint.provisioner
      provisioner.context_resources = x_resources
      provisioner.context = self
      ary.append(provisioner)
    end
  end

  # TODO: add other dirs for config files, e.g. gem user's path; load from a config file?
  # TODO: should only be one runtime per context
  def manifest
    @manifest ||= Manifest.new(config_files_paths: [path(to: :config)], write_path: path(to: :manifests))
  end

  def path(from: nil, to: nil, absolute: false)
    project_path.path(from: from, to: to, absolute: absolute)
  end

  def project_path
    @project_path ||= ProjectPath.new(paths: CnfsCli.config.paths, context_attrs: context_attrs)
  end

  # Used by runtime generators for templates by runtime to query services
  def labels
    @labels ||= begin
      c_hash = components.each_with_object({}) { |c, h| h[c.segment_type] = c.name }
      { 'context' => context_name }.merge(c_hash)
    end
  end

  def context_name
    @context_name ||= context_attrs.join('_')
  end

  def context_attrs
    @context_attrs ||= components.order(:id).pluck(:name)
  end

  # NOTE: Used by console controller to create the CLI prompt
  def component_list
    @component_list ||= all_components.each_with_object([]) { |component, ary| ary.append(component_struct(component)) }
  end

  def all_components
    components.order(:id).to_a.append(component)
  end

  def component_struct(component)
    OpenStruct.new(segment_type: component.owner&.segment_type, name: component.name)
  end

  def options
    Thor::CoreExt::HashWithIndifferentAccess.new(super)
  end

  def args
    Thor::CoreExt::HashWithIndifferentAccess.new(super)
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :root
        t.references :component
        t.string :options
        t.string :args
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
