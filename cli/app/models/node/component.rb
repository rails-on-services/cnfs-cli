# frozen_string_literal: true

class Node::Component < Node
  after_create :make_asset, :load_search_path

  def make_asset
    if parent.nil?
      update(owner: @owner_class.create(yaml_payload))
    else
      super
    end
  end

  # Override Node's definition; Only Component's can be owners
  def owner_ref(obj)
    obj.eql?(self) ? parent.owner_ref(obj) : owner
  end

  # parent must be either SearchPath or ComponentDir
  def owner_ass_name
    'components'
  end
end
