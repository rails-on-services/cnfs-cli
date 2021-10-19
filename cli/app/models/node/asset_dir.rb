# frozen_string_literal: true

class Node::AssetDir < Node
  after_create :load_path

  # Override Node's method because an AssetDir always only contains assets
  def child_node_class_name(_pathname)
    'Node::Asset'
  end

  def valid_load_path_types
    %i[file?]
  end
end
