# frozen_string_literal: true

class Node::SearchPath < Node
  after_create :load_path, unless: proc { skip_owner_create }
  after_create :make_path, if: proc { skip_owner_create }

  def node_for(assn_type)
    # binding.pry
    nodes.select{ |n| n.node_name.eql?(assn_type) }.first
  end

  def make_path
    rootpath.mkdir
  end
end
