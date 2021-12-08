# frozen_string_literal: true

class Node::Asset < Node
  include Concerns::NodeWriter

  # BEGIN: source asset

  after_initialize :identify_parent, if: proc { Node.source.eql?(:asset) }

  delegate :tree_name, to: :owner

  def identify_parent
    return if persisted?

    self.parent = who_parent
    self.path = parent.path
  end

  # rubocop:disable Metrics/AbcSize
  def who_parent
    if candidates.size.zero?
      path = "#{node_component_dir.path}/#{owner.class.table_name}.yml"
      node_component_dir.nodes.create(type: 'Node::AssetGroup', path: path)
    elsif candidates.size.eql?(1)
      candidates.first
    elsif candidates.size.eql?(2)
      candidates.select { |c| c.type.eql?('Node::AssetGroup') }.first
    end
  end
  # rubocop:enable Metrics/AbcSize

  def candidates
    @candidates ||= node_component_dir.nodes.select { |node| node.node_name.eql?(asset_type) }
  end

  def node_component_dir
    # owner is resource
    # owner.owner is resource.owner (Project.first)
    # owner.owner.parent is Project.first's Node::Component
    # owner.owner.parent.dir is Node::Component's Node::ComponentDir
    owner.owner.parent.component_dir
  end

  def asset_type
    owner.class.table_name
  end

  # returns a value to Node#owner_association to call on owner
  def owner_association_name
    parent.node_name
  end

  # If parent is an AssetGroup then delegate writing to the parent
  # If parent is an AssetDir then just write the yaml to realpath
  def write_yaml
    if parent.type.eql?('Node::AssetGroup')
      parent.write_yaml(owner)
    else
      super
    end
  end

  def destroy_yaml
    parent.destroy_yaml(self)
  end
end
