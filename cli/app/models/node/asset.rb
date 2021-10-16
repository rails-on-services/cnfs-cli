# frozen_string_literal: true

class Node::Asset < Node
  after_create :make_asset, :load_search_paths
end
