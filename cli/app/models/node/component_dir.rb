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
      next if ary.size.eql?(2)

      FileUtils.touch("#{ary.first}.yml") if ary.first.directory?
      FileUtils.mkdir(ary.first.to_s.delete_suffix('.yml')) if ary.first.file?
    end
  end
  # rubocop:enable Style/MultilineBlockChain

  # BEGIN: source asset

  after_destroy :destroy_yaml, if: proc { Node.source.eql?(:asset) }

  # Override Node#set_realpath to create the file first, otherwise super will fail due to path not existing
  def set_realpath
    return super if Node.source.eql?(:node) || persisted?

    # binding.pry
    path_n = Pathname.new(path)
    path_n.mkdir unless path_n.exist?
    super
  end

  def destroy_yaml
    rootpath.rmtree
  end
end
