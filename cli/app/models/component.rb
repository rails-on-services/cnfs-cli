# frozen_string_literal: true

class Component < ApplicationRecord
  include Concerns::Parent
  include Concerns::Encryption
  include Concerns::Interpolation

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
    accessors: %i[segment_name runtime_name resource_name provider_name provisioner_name repository_name]
   

  # Return the default dir_path of the parent's path + thsi component's name unless a blueprint_name is configured
  # In which case parse blueprint_name to search the component hierarchy for the specified repository and blueprint
  def dir_path
    ret_val = parent.parent.rootpath.join(parent.node_name).to_s
    return ret_val unless blueprint_name

    bp_repo_name, bp_name = blueprint_name.split('/')

    unless (repo = owner.repositories.find_by(name: bp_repo_name))
      node_warn(node: parent,
                msg: ["Blueprint repository '#{bp_repo_name}' not found", "Component: #{name}"])
      return ret_val 
    end

    unless (path = repo.blueprints[bp_name])
      node_warn(node: parent,
                msg: ["Blueprint '#{bp_name}' not found in repository '#{bp_repo_name}'", "Component: #{name}"])
      return ret_val 
    end

    Cnfs.add_loader(name: blueprint_name, path: path.join('app')).setup
    path.join('config')
  end

  def key
    @key ||= local_file_values['key'] || owner&.key
  end

  def generate_key
    local_file_values.merge!('key' => Lockbox.generate_key)
    write_local_file
  end

  def write_local_file
    local_path.split.first.mkpath unless local_path.split.first.exist?
    File.open(local_file, 'w') { |f| f.write(local_file_values.to_yaml) }
  end

  def local_file_values
    @local_file_values ||= local_file.exist? ? (YAML.load_file(local_file) || {}) : {}
  end

  def local_file
    @local_file ||= local_path.split.first.join("#{attrs.last}.yml")
  end

  def local_path
    @local_path ||= CnfsCli.configuration.data_home.join(*attrs)
  end

  def attrs
    @attrs ||= (owner&.attrs || []).dup.append(name)
  end

  def tree_name
    bp_name = blueprint_name.nil? ? '' : "  source: #{blueprint_name.gsub('/', '-')}"
    "#{name} (#{owner.segment_type})#{bp_name}"
  end

  # def x_config
  #   Config::Options.new.merge!(config)
  # end

  # Display components as a TreeView
  def to_tree
    puts "\n#{as_tree.render}"
  end

  def as_tree
    TTY::Tree.new("#{name} (#{self.class.name.underscore})" => tree)
  end

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
        t.string :blueprint_name
        t.string :type
        t.string :segment_type
        t.string :default
        t.string :config
        t.references :owner
      end
    end
  end
end
