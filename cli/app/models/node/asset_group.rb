# frozen_string_literal: true

class Node::AssetGroup < Node
  after_create :make_nodes_from_yaml

  def make_nodes_from_yaml
    yaml.each do |key, values|
      values.merge!('name' => key)
      Node::Asset.create(parent: self, config: config, path: path, calc_type: calc_type.singularize, yaml_payload: values)
    end
  end
end
