# frozen_string_literal: true

class Node::Asset < Node
  after_create :make_owner, :load_search_path, if: proc { Node.source.eql?(:node) }

  after_initialize :identify_parent, if: proc { Node.source.eql?(:asset) }
  after_update :update_yaml, if: proc { Node.source.eql?(:asset) }

  delegate :tree_name, to: :owner

  # parent must be either AssetGroup or AssetDir
  def owner_ass_name
    parent.node_name
  end

  def identify_parent
    assn_type = owner.class.name.underscore.pluralize
    # who could my parent be? AssetGroup or AssetDir
    # who could my owner's owner be? Component
    # possible nodes:
    if (this_one = owner.owner.parent.node_for(assn_type))
      self.parent = this_one
      self.path = this_one.path
    else
      # TODO: Handle no return of a parent
      binding.pry
    end
    parent.update_yaml(owner)
  end

  def update_yaml
    binding.pry
    parent.update_yaml(owner)
  end
end
