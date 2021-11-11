# frozen_string_literal: true

class Node::Component < Node
  after_create :make_owner, :load_search_path, if: proc { Node.source.eql?(:node) }
  after_create :update_yaml, if: proc { Node.source.eql?(:asset) }
  after_update :update_yaml

  delegate :tree_name, to: :owner

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
    new_yaml = owner.as_json_encrypted.to_yaml
    Cnfs.logger.debug("Writing to #{realpath} with\n#{new_yaml}")
    File.open(realpath, 'w') { |f| f.write(new_yaml) }
  end
end
