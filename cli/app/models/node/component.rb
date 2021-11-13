# frozen_string_literal: true

class Node::Component < Node
  attr_writer :dir_path

  after_create :make_owner, :load_dir_path, if: proc { Node.source.eql?(:node) }

  # If it exists and is a directory then create a SearchPath object which will query the child nodes
  def load_dir_path
    component_path = Pathname.new(dir_path)
    # binding.pry
    return unless component_path.directory? && component_path.exist?

    nodes.create(path: component_path.to_s, type: 'Node::ComponentDir')
  end

  # The default dir_path is the same name as the component file but with '.yml' stripped
  def dir_path
    @dir_path ||= (owner.respond_to?(:dir_path) ? owner.dir_path : "#{parent.parent.dir_path}/#{node_name}")
  end

  # Override Node's definition; Only Components are owners
  def owner_ref(obj)
    obj.eql?(self) ? parent.owner_ref(obj) : owner
  end

  # returns a value to Node#owner_association to call on owner
  def owner_association_name
    'components'
  end

  # BEGIN: source asset

  after_create :update_yaml, if: proc { Node.source.eql?(:asset) }
  after_update :update_yaml, if: proc { Node.source.eql?(:asset) }

  def component_dir
    return '' if parent.nil?
    if (dir = parent.nodes.select { |n| n.class.name.eql?('Node::ComponentDir') && n.node_name.eql?(node_name) }.first)
      return dir
    end
    binding.pry
    nodes.create(type: 'Node::ComponentDir', path: '')
  end

  def node_for(assn_type)
    Cnfs.logger.warn(nodes.first&.type)
    # binding.pry
    if nodes.first.type.eql?('Node::SearchPath')
      nodes.first.node_for(assn_type)
    else
      ns = nodes.select{ |n| n.node_name.eql?(assn_type) }
      return ns.first if ns.first
      # binding.pry
    end
  end

  def update_yaml
    new_yaml = owner.as_json_encrypted.to_yaml
    Cnfs.logger.debug("Writing to #{realpath} with\n#{new_yaml}")
    File.open(realpath, 'w') { |f| f.write(new_yaml) }
  end

  delegate :tree_name, to: :owner
end
