# frozen_string_literal: true

class Node::AssetDir < Node
  after_create :create_asset_nodes, if: proc { Node.source.eql?(:node) }

  def create_asset_nodes
    pathname.children.select(&:file?).each do |path_name|
      nodes.create(type: 'Node::Asset', path: path_name.to_s)
    end
  end

  # BEGIN: source asset

  after_create :make_path, if: proc { Node.source.eql?(:asset) }

  # TODO: Is necessary?
  def make_path
    # binding.pry
    rootpath.mkdir
  end

  # Called from Asset
  def destroy_yaml(asset)
    Cnfs.logger.debug("Deleting #{realpath}")
    FileUtils.rm(asset.realpath)
    return if rootpath.children.size.positive?

    rootpath.rmtree
    destroy
  end
end
