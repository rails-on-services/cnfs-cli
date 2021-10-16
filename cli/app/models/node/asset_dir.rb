# frozen_string_literal: true

class Node::AssetDir < Node
  after_create :load_path
end
