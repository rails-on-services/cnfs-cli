# frozen_string_literal: true

class Node::AssetDir < Node
  after_create :make_nodes, if: proc { Node.source.eql?(:node) }

  def make_nodes
    pathname.children.select(&:file?).each do |c_pathname|
      nodes.create(path: c_pathname.to_s, type: 'Node::Asset')
    end
  end

  # BEGIN: source asset

  after_create :make_path, if: proc { Node.source.eql?(:asset) }

  def make_path
    rootpath.mkdir
  end
end
