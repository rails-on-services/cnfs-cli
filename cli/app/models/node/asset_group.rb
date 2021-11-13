# frozen_string_literal: true

class Node::AssetGroup < Node
  after_create :make_nodes, if: proc { Node.source.eql?(:node) }

  def make_nodes
    # binding.pry
    yaml.each do |key, values|
      values = { 'name' => key }.merge(values)
      # Node::Asset.create(parent: self, path: path, yaml_payload: values)
      nodes.create(path: path, yaml_payload: values, type: 'Node::Asset')
    end
  end

  # BEGIN: source asset

  def update_yaml(new_owner)
    new_yaml = yaml.merge(new_owner.name => new_owner.as_json_encrypted)
    # binding.pry
    Cnfs.logger.debug("Writing to #{realpath} with\n#{new_yaml}")
    File.open(realpath, 'w') { |f| f.write(new_yaml.to_yaml) }
  end

  def tree_name
    { node_name => nodes.map(&:tree_name) }
  end
end
