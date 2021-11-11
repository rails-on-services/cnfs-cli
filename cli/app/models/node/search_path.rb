# frozen_string_literal: true

class Node::SearchPath < Node
  after_create :load_path, if: proc { Node.source.eql?(:node) }
  after_create :make_path, if: proc { Node.source.eql?(:asset) }

  def node_for(assn_type)
    # binding.pry
    nodes.select{ |n| n.node_name.eql?(assn_type) }.first
  end

  def make_path
    rootpath.mkdir
  end
end
