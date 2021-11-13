# frozen_string_literal: true

class Node::ComponentDir < Node
  after_create :load_path, if: proc { Node.source.eql?(:node) }
  # after_create :make_owner, :load_path, if: proc { Node.source.eql?(:node) }
  after_create :make_path, if: proc { Node.source.eql?(:asset) }

  def make_path
    rootpath.mkdir
  end

  # Iterate over files and directories
  def load_path
    # ComponentDirs contain assets (repositories.yml, repositories/). Create these first
    pathname.children.sort.select{ |n| CnfsCli.asset_names.include?(base_name(n)) }.each do |path_name|
      nodes.create(path: path_name.to_s, type: (path_name.directory? ? 'Node::AssetDir' : 'Node::AssetGroup'))
    end
    # If a component dir exsists but not the file then create the file
    pathname.children.reject{ |n| CnfsCli.asset_names.include?(base_name(n)) }.group_by {|n| base_name(n) }.each do |name, ary|
      FileUtils.touch("#{ary.first}.yml") if ary.size.eql?(1) && ary.first.directory?
    end
    # Create Components
    pathname.children.select(&:file?).reject{ |n| CnfsCli.asset_names.include?(base_name(n)) }.each do |c_pathname|
      _n = nodes.create(path: c_pathname.to_s, type: child_node_class_name(c_pathname))
    end
  end

  # def tree_name
  #   node_name
  # end

  def x_load_path
    %i[file? directory?].each do |node_type|
      pathname.children.select(&node_type).each do |c_pathname|
        _n = nodes.create(path: c_pathname.to_s, type: child_node_class_name(c_pathname))
      end
    end
  end

  # Based on the pathname type, dir or file, and the pluralization of the basename
  # return the appropriate node sub-class as a string
  def child_node_class_name(c_pathname)
    n_name = base_name(c_pathname)
    class_name = if c_pathname.directory?
      n_name.eql?(n_name.pluralize) ? 'AssetDir' : 'ComponentDir'
    else
      n_name.eql?(n_name.pluralize) ? 'AssetGroup' : 'Component'
    end
    "Node::#{class_name}"
  end

  def node_for(assn_type)
    # binding.pry
    nodes.select{ |n| n.node_name.eql?(assn_type) }.first
  end

  # def owner_ass_name
  #   'components'
  # end

  # def yaml_payload 
  #   @yaml_payload ||= { 'name' => node_name }
  # end

  # def tree_name
  #   { node_name => nodes.map(&:owner).map(&:name) }
  # end
end
