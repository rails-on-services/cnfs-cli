# frozen_string_literal: true

class Node::SearchPath < Node
  after_create :load_path
end
