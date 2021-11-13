# frozen_string_literal: true

class Node < ApplicationRecord
  attr_writer :yaml_payload, :owner_class

  belongs_to :parent, class_name: 'Node'
  belongs_to :owner, polymorphic: true
  has_many :nodes, class_name: 'Node', foreign_key: 'parent_id'

  before_validation :set_realpath

  def set_realpath
    # binding.pry unless path
    # self.realpath ||= Pathname.new(path).realpath.to_s
    self.realpath ||= Pathname.new(path).cleanpath.to_s
  end

  # This only applies to Component and Asset
  def make_owner
    return if CnfsCli.support_names.include?(node_name)

    obj = parent.nil? ? @owner_class.create(yaml_payload) : owner_association.create(yaml_payload)
    return unless obj

    update(owner: obj)
    owner_log('Created owner')
  rescue ActiveModel::UnknownAttributeError, ActiveRecord::AssociationTypeMismatch, ActiveRecord::RecordInvalid => e
    binding.pry
    Cnfs.logger.warn(e.message, yaml_payload)
    owner_log('Error creating owner')
  rescue NoMethodError => err
    Cnfs.logger.warn("#{err.message} in #{realpath}")
  end

  # Returns an A/R association, e.g. components, resources, etc
  # owner_association_name is implemented in Node::Component and Node::Asset
  def owner_association
    owner_ref(self).send(owner_association_name.to_sym)
  end

  # Returns a Component instance by searching recursively up the current node's parent hierarch
  # until reaching a Node::Component which overrides this method and returns it's owner
  def owner_ref(obj)
    parent.owner_ref(obj)
  end

  # Component, Asset and AssetGroup
  def yaml_payload
    @yaml_payload ||= { 'name' => node_name }.merge(yaml)
  end

  def yaml(reload: false)
    return @yaml ||= YAML.load_file(rootpath) || {} unless reload

    @yaml = YAML.load_file(rootpath) || {}
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

  def owner_log(title)
    Cnfs.logger.debug("#{title} from: #{pathname}\n#{yaml_payload}")
  end

  def root_tree
    puts "\n#{TTY::Tree.new(owner.name => nodes.first.tree).render}"
  end

  def tree
    nodes.each_with_object([]) do |node, ary|
      if node.type.eql?('Node::Asset')
        ary.append(node.tree_name)
      elsif node.type.eql?('Node::Component')
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
      (CnfsCli.asset_names.append('component')).map { |name| name.classify.constantize }
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
