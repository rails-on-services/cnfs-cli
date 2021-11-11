# frozen_string_literal: true

class Node::ComponentDir < Node
  after_create :make_owner, :load_path, if: proc { Node.source.eql?(:node) }
  after_create :make_path, if: proc { Node.source.eql?(:asset) }

  def make_path
    rootpath.mkdir
  end

  # If 
  def make_owner
    if (obj = owner_ref(self).components.find_by(name: node_name))
      update(owner: obj)
    else
      super
    end
  end

  def owner_ref(obj)
    obj.eql?(self) ? parent.owner_ref(obj) : owner
  end

  def owner_ass_name
    'components'
  end

  def yaml_payload 
    @yaml_payload ||= { 'name' => node_name }
  end

  # def tree_name
  #   { node_name => nodes.map(&:owner).map(&:name) }
  # end
end
