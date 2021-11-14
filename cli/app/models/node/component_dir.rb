# frozen_string_literal: true

class Node::ComponentDir < Node
  after_create :load_path, if: proc { Node.source.eql?(:node) }

  # Iterate over files and directories
  # rubocop:disable Metrics/AbcSize
  def load_path
    # ComponentDirs contain assets (repositories.yml, repositories/). Create these first
    pathname.children.sort.select { |n| CnfsCli.asset_names.include?(base_name(n)) }.each do |path_name|
      node_type = path_name.directory? ? 'Node::AssetDir' : 'Node::AssetGroup'
      nodes.create(type: node_type, path: path_name.to_s)
    end
    check_components(pathname)
    # Create Components
    pathname.children.select(&:file?).reject { |n| CnfsCli.asset_names.include?(base_name(n)) }.each do |path_name|
      nodes.create(type: 'Node::Component', path: path_name.to_s)
    end
  end
  # rubocop:enable Metrics/AbcSize

  # If a component dir exsists but not the file then create the file
  # rubocop:disable Style/MultilineBlockChain
  def check_components(path_name)
    path_name.children.reject do |n|
      CnfsCli.asset_names.include?(base_name(n))
    end.group_by { |n| base_name(n) }.each do |_name, ary|
      FileUtils.touch("#{ary.first}.yml") if ary.size.eql?(1) && ary.first.directory?
    end
  end
  # rubocop:enable Style/MultilineBlockChain

  # BEGIN: source asset

  after_create :make_path, if: proc { Node.source.eql?(:asset) }

  def make_path
    rootpath.mkdir
  end
end
