# frozen_string_literal: true

class Node::AssetGroup < Node
  after_create :make_nodes_from_yaml

  def make_nodes_from_yaml
    yaml.each do |key, values|
      values.merge!('name' => key)
      Node::Asset.create(parent: self, path: path, yaml_payload: values)
    end
  end

  def update_yaml(new_owner)
    new_yaml = yaml.merge(new_owner.name => new_owner.as_json)
    binding.pry
    Cnfs.logger.debug("Writing to #{realpath} with\n#{new_yaml}")
    File.open(realpath, 'w') { |f| f.write(new_yaml.to_yaml) }
  end

  def tree_name
    { node_name => nodes.map(&:tree_name) }
  end
end
