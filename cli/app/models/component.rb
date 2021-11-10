# frozen_string_literal: true

class Component < ApplicationRecord
  include Concerns::Encryption
  include Concerns::Interpolate

  attr_accessor :skip_node_create
  attr_encrypted :test #, :config

  belongs_to :owner, class_name: 'Component'
  has_one :parent, as: :owner, class_name: 'Node'
  has_one :context

  has_many :components, foreign_key: 'owner_id'

  has_many :context_components
  has_many :contexts, through: :context_components

  # Pluralized resource names are declared as a has_many
  CnfsCli.asset_names.select{ |name| name.pluralize.eql?(name) }.each do |asset_name|
    has_many asset_name.to_sym, as: :owner
  end

  store :config, coder: YAML

  validates :name, presence: true

  before_create :decrypt, unless: proc { skip_node_create }
  after_create :create_node, unless: proc { skip_node_create }
  after_update :update_node, unless: proc { skip_node_create }

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

  # def x_config
  #   Config::Options.new.merge!(config)
  # end

  def c_name
    owner.child_name
  end

  def except_json
    super.append('type')
  end

  def create_node
    binding.pry
    create_parent(type: 'Node::ComponentDir', path: name, owner: self, parent: owner.parent, skip_owner_create: true)
  end

  def update_node
    parent.update(owner: self, skip_owner_create: true)
  end

  def root_tree
    TTY::Tree.new("#{name} (project)" => tree)
  end

  def tree
    components.each_with_object([]) do |comp, ary|
      if comp.components.size.zero?
        ary.append("#{comp.name} (#{comp.c_name})")
      else
        ary.append({ "#{comp.name} (#{comp.c_name})" => comp.tree })
      end
    end
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :owner
        t.string :name
        t.string :config
        t.string :type
        t.string :child_name
        t.string :default
        t.binary :test
      end
    end
  end
end
