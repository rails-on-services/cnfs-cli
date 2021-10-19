# frozen_string_literal: true

class Node::Asset < Node
  after_create :make_asset, :load_search_path

  # parent must be either AssetGroup or AssetDir
  def asset_ass_name
    parent.node_name
  end
end
