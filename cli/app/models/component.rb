# frozen_string_literal: true

class Component < ApplicationRecord
  include Concerns::Parent
  include Concerns::Extendable

  belongs_to :owner, class_name: 'Component'
  has_one :parent, as: :owner, class_name: 'Node'
  has_one :context

  has_many :components, foreign_key: 'owner_id'

  has_many :context_components
  has_many :contexts, through: :context_components

  # Pluralized resource names are declared as a has_many
  CnfsCli.asset_names.select { |name| name.pluralize.eql?(name) }.each do |asset_name|
    has_many asset_name.to_sym, as: :owner
  end

  store :default, coder: YAML,
    accessors: %i[blueprint_name provider_name provisioner_name repository_name resource_name runtime_name segment_name]

  # Return the default dir_path of the parent's path + this component's name unless a component_name is configured
  # In which case parse component_name to search the component hierarchy for the specified repository and blueprint
  def dir_path
    if component_name
      if (path = CnfsCli.components[component_name])
        return path.join('component')
      else
        node_warn(node: parent, msg: "Repository component '#{component_name}' not found")
      end
    end
    parent.parent.rootpath.join(parent.node_name).to_s
  end

  # Key search priorities:
  # 1. ENV var
  # 2. Project's data_path/keys.yml
  # 3. Owner's key
  def key() = @key ||= ENV[key_name_env] || local_file_read(path: keys_file).fetch(key_name, owner&.key)

  # 1_target/backend => 1_target_backend
  def key_name() = @key_name ||= "#{owner.key_name}_#{name}"

  # 1_target/backend => CNFS_KEY_BACKEND
  def key_name_env() = @key_name_env ||= "#{owner.key_name_env}_#{name.upcase}"

  def keys_file() = @keys_file ||= CnfsCli.config.data_home.join('keys.yml')

  def generate_key
    key_file_values = local_file_read(path: keys_file).merge(new_key)
    local_file_write(path: keys_file, values: key_file_values)
  end

  def new_key() = { key_name => Lockbox.generate_key }

  # Read/Write 'runtime' component data to this file
  def cache_file() = @cache_file ||= owner.cache_path.join("#{name}.yml")

  # This component's local file to provide local overrides to project values, e.g. change default runtime_name
  # The user must maintain these files locally
  # These values are merged for runtime so they are not saved into the project's files
  def data_file() = @data_file ||= owner.data_path.join("#{name}.yml")

  # Operators and Context's Assets can read/write their 'runtime' data into this directory
  def cache_path() = @cache_path ||= owner.cache_path.join(name)

  # Child Components and Assets can read their local overrides into this directory
  def data_path() = @data_path ||= owner.data_path.join(name)

  def attrs() = @attrs ||= owner.attrs.dup.append(name)

  def tree_name
    bp_name = component_name.nil? ? '' : "  source: #{component_name.gsub('/', '-')}"
    "#{name} (#{owner.segment_type})#{bp_name}"
  end

  def as_merged() = as_json

  # Display components as a TreeView
  def to_tree() = puts('', as_tree.render)

  def as_tree() = TTY::Tree.new("#{name} (#{self.class.name.underscore})" => tree)

  def tree
    components.each_with_object([]) do |comp, ary|
      if comp.components.size.zero?
        ary.append("#{comp.name} (#{comp.type})")
      else
        ary.append({ "#{comp.name} (#{comp.type})" => comp.tree })
      end
    end
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :component_name
        t.string :type
        t.string :segment_type
        t.string :default
        t.string :config
        t.references :owner
      end
    end
  end
end
