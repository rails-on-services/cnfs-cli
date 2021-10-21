# frozen_string_literal: true

class Node::ComponentDir < Node
  after_create :make_owner, :load_path

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
end
