# frozen_string_literal: true

class Node::Component < Node
  include Concerns::NodeWriter

  attr_writer :dir_path

  after_create :load_dir_path, if: proc { Node.source.eql?(:node) }

  # Create a ComponentDir object to query the child nodes if the directory exists on the filesystem
  def load_dir_path
    component_path = Pathname.new(dir_path)
    nodes.create(type: 'Node::ComponentDir', path: component_path.to_s) if component_path.exist?
  end

  # The default dir_path is the same name as the component file but with '.yml' stripped
  def dir_path
    @dir_path ||= (owner.respond_to?(:dir_path) ? owner.dir_path : "#{parent.parent.dir_path}/#{node_name}")
  end

  # Override Node's definition to return owner unless calling owner_ref on self
  # Components are the only type that can return an owner
  def owner_ref(obj)
    obj.eql?(self) ? parent.owner_ref(obj) : owner
  end

  # returns a value to Node#owner_association to call on owner
  def owner_association_name() = 'components'

  # BEGIN: source asset

  # Override Node#set_realpath to create the file first, otherwise super will fail due to path not existing
  def set_realpath
    return super if Node.source.eql?(:node) || persisted?

    self.parent ||= owner.owner.parent.component_dir
    base_path = "#{parent.path}/#{owner.name}"
    self.path ||= "#{base_path}.yml"
    FileUtils.touch(path)
    binding.pry
    nodes << Node::ComponentDir.new(path: base_path)
    super
  end

  # Called by Asset to get the ComponentDir in which its AssetDir or AssetGroup is located
  def component_dir() = nodes.first

  def destroy_yaml
    Cnfs.logger.debug("Deleting #{realpath}")
    component_dir.destroy
    FileUtils.rm(realpath)
  end

  delegate :tree_name, to: :owner

  def to_tree() = puts("\n#{as_tree.render}")

  def as_tree() = TTY::Tree.new(owner.name => nodes.first.tree)
end
