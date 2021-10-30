# frozen_string_literal: true

class Node::Component < Node
  after_create :make_owner, :load_search_path, unless: proc { skip_owner_create }
  after_create :update_yaml, if: proc { skip_owner_create }
  after_update :update_yaml

  # Override Node's definition; Only Component's can be owners
  def owner_ref(obj)
    obj.eql?(self) ? parent.owner_ref(obj) : owner
  end

  # parent must be either SearchPath or ComponentDir
  def owner_ass_name
    'components'
  end

  def node_for(assn_type)
    # binding.pry
    if nodes.first.type.eql?('Node::SearchPath')
      nodes.first.node_for(assn_type)
    else
      ns = nodes.select{ |n| n.node_name.eql?(assn_type) }
      return ns.first if ns.first
      binding.pry
    end
  end

  def update_yaml
    new_yaml = owner.as_json.to_yaml
    Cnfs.logger.debug("Writing to #{realpath} with\n#{new_yaml}")
    File.open(realpath, 'w') { |f| f.write(new_yaml) }
  end

  def tree_name
    "#{owner.name} (#{owner.c_name})"
  end
end
