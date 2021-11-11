# frozen_string_literal: true

class Node < ApplicationRecord
  attr_writer :yaml_payload, :owner_class

  belongs_to :parent, class_name: 'Node'
  belongs_to :owner, polymorphic: true
  has_many :nodes, class_name: 'Node', foreign_key: 'parent_id'

  before_validation :set_realpath

  def set_realpath
    binding.pry unless path
    # self.realpath ||= Pathname.new(path).realpath.to_s
    self.realpath ||= Pathname.new(path).cleanpath.to_s
  end

  # This only applies to Component, ComponentDir and Asset
  def make_owner
    return if CnfsCli.support_names.include?(node_name)

    # binding.pry if parent.nil?
    obj = parent.nil? ? @owner_class.create(yaml_payload) : make_owner_association
    return unless obj

    update(owner: obj)
    owner_log('Created owner')
  rescue ActiveModel::UnknownAttributeError, ActiveRecord::AssociationTypeMismatch, ActiveRecord::RecordInvalid => e
    Cnfs.logger.warn(e.message, yaml_payload)
    owner_log('Error creating owner')
  end

  def make_owner_association
    own = owner_ref(self)
    assn_str = owner_ass_name
    assn = own.send(assn_str.to_sym)
    assn.create(yaml_payload)
  rescue NoMethodError => err
    # Cnfs.logger.warn("unknown resource #{err.message.split[2]} found at #{realpath}")
    Cnfs.logger.warn("#{err.message} in #{realpath}")
    nil
  end

  # Recursively move back through parent hierarchy until reaching a Node::Component which
  # overrides this method and returns it's owner
  def owner_ref(obj)
    parent.owner_ref(obj)
  end

  # AssetGroup, Asset and Component (ComponentDir sort of)
  def yaml_payload
    @yaml_payload ||= { 'name' => node_name }.merge(yaml)
  end

  def yaml(reload: false)
    return @yaml ||= YAML.load_file(rootpath) || {} unless reload

    @yaml = YAML.load_file(rootpath) || {}
  end

  # Query the just created asset or component for a search_path
  # If it exists and is a directory then create a SearchPath object which will query the child nodes
  def load_search_path
    return unless owner.respond_to?(:search_path) && (search_path = owner.search_path)
    return unless search_path.directory? && search_path.exist?

    _n = nodes.create(path: search_path.to_s, type: 'Node::SearchPath')
  end

  # Called by AssetDir, ComponentDir and SearchPath to iterate over their children
  def load_path
    valid_load_path_types.each do |node_type|
      pathname.children.select(&node_type).each do |c_pathname|
        _n = nodes.create(path: c_pathname.to_s, type: child_node_class_name(c_pathname))
      end
    end
  end

  def valid_load_path_types
    %i[file? directory?]
  end

  # Based on the pathname type, dir or file, and the pluralization of the basename
  # return the appropriate node sub-class as a string
  def child_node_class_name(pathname)
    n_name = pathname.basename.to_s.delete_suffix(pathname.extname)
    class_name = if pathname.directory?
      n_name.eql?(n_name.pluralize) ? 'AssetDir' : 'ComponentDir'
    else
      n_name.eql?(n_name.pluralize) ? 'AssetGroup' : 'Component'
    end
    "Node::#{class_name}"
  end

  def node_name
    @node_name ||= pathname.basename.to_s.delete_suffix(pathname.extname)
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
    puts "\n#{TTY::Tree.new(node_name => tree).render}"
  end

  # TODO: Use the subclasses to determine what should be returned
  def tree
    ret = nodes.select{ |c| c.rootpath.file? }.map(&:tree_name)
    ret.append(
      nodes.select{ |c| c.rootpath.directory? }.each_with_object({}) do |node, hash|
        hash["#{node.node_name} (#{node.owner&.c_name})"] = node.tree
      end
    )
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
