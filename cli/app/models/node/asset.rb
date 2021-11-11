# frozen_string_literal: true

class Node::Asset < Node
  after_create :make_owner, :load_search_path, unless: proc { skip_owner_create }
  after_initialize :identify_parent, if: proc { skip_owner_create }
  after_update :update_yaml, if: proc { skip_owner_create }

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
    parent.update_yaml(owner)
  end

  def tree_name
    owner.tree_name
  end
end
