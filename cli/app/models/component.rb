# frozen_string_literal: true

class Component < ApplicationRecord
  attr_accessor :skip_node_create

  belongs_to :owner, class_name: 'Component'
  has_one :parent, as: :owner, class_name: 'Node'

  has_many :components, foreign_key: 'owner_id'

  has_many :context_components
  has_many :contexts, through: :context_components

  # Pluralized resource names are declared as a has_many
  CnfsCli.asset_names.select{ |name| name.pluralize.eql?(name) }.each do |asset_name|
    has_many asset_name.to_sym, as: :owner
  end # if false

  store :config, accessors: %i[child_c_name], coder: YAML

  validates :name, presence: true

  after_create :create_node, unless: proc { skip_node_create }
  after_update :update_node, unless: proc { skip_node_create }

  def c_name
    owner.child_name
  end

  def except_json
    super.append('type')
  end

  # def context
  #   @context ||= create_context
  # end

  def create_node
    binding.pry
    create_parent(type: 'Node::ComponentDir', path: name, owner: self, parent: owner.parent, skip_owner_create: true)
  end

  def update_node
    # parent.update(owner: self)
    parent.update(owner: self, skip_owner_create: true)
  end

  # updates this component's context and it's owner's context (recursive until owner is nil)
  def update_context(context:)
    update(context: context)
    owner&.update_context(context: context)
  end

  def runtime
    resource&.runtime
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

  # Scan all resources for a runtime association
  # If none is found then recursively call the owning component looking for a runtime
  # If none or multiple runtimes are found log a warning and return nil
  def resource
    runtime_resources = resources.select(&:runtime)
    size = runtime_resources.size
    if size.zero?
      Cnfs.logger.warn('No defined runtimes') if owner.nil?
      owner&.resource
    elsif size.eql?(1)
      runtime_resources.first
    else
      Cnfs.logger.warn("Multiple defined runtimes found in: #{runtime_resources.map(&:name).join(' ')}")
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
      end
    end
  end
end
