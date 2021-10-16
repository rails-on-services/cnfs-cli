# frozen_string_literal: true

class Node::ComponentDir < Node
  after_create :load_path

  # def create_assets?
  #   !(pathname.sub_ext('.yml').exist? || pathname.sub_ext('.yaml').exist?)
  # end
end
