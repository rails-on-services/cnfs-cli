# frozen_string_literal: true

class Node::Asset < Node
  after_create :make_owner, if: proc { Node.source.eql?(:node) }
  # after_create :make_owner, :load_search_path, if: proc { Node.source.eql?(:node) }

  # BEGIN: source asset

  after_initialize :identify_parent, if: proc { Node.source.eql?(:asset) }
  after_create :create_yaml, if: proc { Node.source.eql?(:asset) }
  after_update :update_yaml, if: proc { Node.source.eql?(:asset) }

  delegate :tree_name, to: :owner

  # returns a value to Node#owner_association to call on owner
  def owner_association_name
    parent.node_name
  end

  def create_yaml
    parent.update_yaml(owner)
  end

  def identify_parent
    return if persisted?
    self.parent = who_parent
    self.path = parent.path 
  end

  def who_parent
    if candidates.size.zero?
      node_component_dir.nodes.create(type: 'Node::AssetGroup')
    elsif candidates.size.eql?(1)
      candidates.first
    elsif candidates.size.eql?(2)
      candidates.select { |c| c.type.eql?('Node::AssetGroup') }.first
    end
  end

  def candidates
    @candidates ||= node_component_dir.nodes.select { |node| node.node_name.eql?(asset_type) }
  end

  def node_component_dir
    # owner is resource
    # owner.owner is resource.owner (Project.first)
    # owner.owner.parent is Project.first's Node::Component
    # owner.owner.parent.dir is Node::Component's Node::ComponentDir
    owner.owner.parent.dir
  end

  def asset_type
    owner.class.table_name
  end

  def update_yaml
    if parent.class.name.eql?('Node::AssetGroup')
      # binding.pry
      parent.update_yaml(owner)
    end
  end
end
