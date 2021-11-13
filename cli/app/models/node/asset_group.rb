# frozen_string_literal: true

class Node::AssetGroup < Node
  after_create :create_asset_nodes, if: proc { Node.source.eql?(:node) }

  def create_asset_nodes
    yaml.each do |key, values|
      values = { 'name' => key }.merge(values)
      nodes.create(type: 'Node::Asset', path: path, yaml_payload: values)
    end
  end

  # BEGIN: source asset

  # after_create :make_path, if: proc { Node.source.eql?(:asset) }

  # Override Node#set_realpath to create the file first, otherwise super will fail due to path not existing
  def set_realpath
    FileUtils.touch(path) unless File.exist?(path)
    super
  end

  # TODO: Is necessary?
  def make_path
    binding.pry
    FileUtils.touch(rootpath)
  end

  def write_yaml(owner)
    write_file(yaml.merge(owner.name => owner.as_json_encrypted))
  end

  def destroy_yaml(asset)
    write_file(yaml.except(asset.owner.name))
  end

  def write_file(yaml_to_write)
    if yaml_to_write.empty?
      FileUtils.rm(realpath)
      destroy
      return
    end
    Cnfs.logger.debug("Writing to #{realpath} with\n#{yaml_to_write}")
    File.open(realpath, 'w') { |f| f.write(yaml_to_write.to_yaml) }
  end

  def tree_name
    { node_name => nodes.map(&:tree_name) }
  end
end
