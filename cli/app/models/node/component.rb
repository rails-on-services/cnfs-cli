# frozen_string_literal: true

class Node::Component < Node
  after_create :make_asset, :load_search_paths

  def owner_hash(obj)
    if obj.class.name != self.class.name # If obj is not a component then return this component's asset
      { owner: asset } 
    elsif obj.eql?(self) # if this is self referencing then return empty hash if root node, otherwise call parent
      parent.try(:owner_hash, obj) || {}
    else # obj is a child of this component so return the asset
      { asset.class.name.downcase => asset }
    end
  end
end
