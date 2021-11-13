# frozen_string_literal: true

class Node < ApplicationRecord
  belongs_to :parent, class_name: 'Node'
  belongs_to :owner, polymorphic: true
  has_many :nodes, class_name: 'Node', foreign_key: 'parent_id'

  before_validation :set_realpath

  def set_realpath
    self.realpath ||= Pathname.new(path).realpath.to_s
  end

  # Returns a Component instance by searching recursively up the current node's parent hierarchy
  # until reaching a Node::Component which overrides this method and returns its owner
  def owner_ref(obj)
    parent.owner_ref(obj)
  end

  def yaml(reload: false)
    @yaml = nil if reload
    @yaml ||= YAML.load_file(rootpath) || {}
  end

  def node_name
    @node_name ||= base_name(pathname)
  end

  def base_name(path_name)
    path_name.basename.to_s.delete_suffix(path_name.extname)
  end

  def pathname
    @pathname ||= Pathname.new(path)
  end

  def rootpath
    @rootpath ||= Pathname.new(realpath)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def tree
    nodes.each_with_object([]) do |node, ary|
      case node.type
      when 'Node::Asset'
        ary.append(node.tree_name)
      when 'Node::Component'
        if node.nodes.any?
          ary.append({ node.tree_name => node.nodes.first.tree })
        else
          ary.append(node.tree_name)
        end
      else
        ary.append({ node.node_name => node.tree })
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  class << self
    attr_reader :source

    def source=(source)
      @source = source.to_s.downcase.to_sym
    end

    def with_asset_callbacks_disabled
      self.source = :node

      assets_to_disable.each do |asset|
        asset.node_callbacks.each { |callback| asset.skip_callback(*callback) }
      end

      yield

      assets_to_disable.each do |asset|
        asset.node_callbacks.each { |callback| asset.set_callback(*callback) }
      end

      self.source = :asset
    end

    def assets_to_disable
      CnfsCli.asset_names.append('component').map { |name| name.classify.constantize }
    end

    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :parent
        t.references :owner, polymorphic: true
        t.string :type
        t.string :path
        t.string :realpath
      end
    end
  end
end
