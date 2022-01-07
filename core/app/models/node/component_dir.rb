# frozen_string_literal: true

class Node::ComponentDir < Node
  after_create :load_path, if: proc { Node.source.eql?(:node) }

  delegate :owner, to: :parent

  # Iterate over files and directories
  def load_path
    # TODO: Could this be used to load app dir and blueprint.yml?
    # If not remove it
    owner.before_load_path(rootpath, self) if owner.respond_to?(:before_load_path)
    create_assets
    validate_if_segment
    create_components
  end

  def create_assets
    asset_paths.each do |path_name|
      node_type = path_name.directory? ? 'Node::AssetDir' : 'Node::AssetGroup'
      nodes.create(type: node_type, path: path_name.to_s)
    end
  end

  # Return files and directories whose names are found in the asset_name array e.g. resources.yml, resources/
  def asset_paths
    search_path.children.select { |n| Cnfs::Core.asset_names.include?(base_name(n)) }.sort
  end

  # Create Node::Components for each found component
  def create_components
    component_file_paths.each do |path_name|
      nodes.create(type: 'Node::Component', path: path_name.to_s)
    end
  end

  def component_file_paths
    search_path.children.select(&:file?).reject { |n| Cnfs::Core.asset_names.include?(base_name(n)) }
  end

  def component_dir_paths
    search_path.children.select(&:directory?).reject { |n| Cnfs::Core.asset_names.include?(base_name(n)) }
  end

  # If the component has the search_path method then only search in that path
  def search_path
    @search_path ||= pathname.join(owner.respond_to?(:search_path) ? owner.search_path : '')
  end

  # If a component dir exsists but not the file then create the file and vice versa
  # So that component crud can rely on the filesystem being available
  def validate_if_segment
    return unless owner.type.nil?

    dirs = component_dir_paths.map { |p| base_name(p) }
    files = component_file_paths.map { |p| base_name(p) }
    (files - dirs).each { |path| search_path.join(path).mkdir }
    (dirs - files).each { |path| FileUtils.touch(search_path.join("#{path}.yml")) }
  end

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
