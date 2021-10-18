# frozen_string_literal: true

class Node < ApplicationRecord
  attr_writer :yaml_payload, :asset_class

  belongs_to :parent, class_name: 'Node'
  # Move asset to Asset class
  belongs_to :asset, polymorphic: true
  belongs_to :config, class_name: 'NodeConfig'
  has_many :nodes, class_name: 'Node', foreign_key: 'parent_id'

  delegate :asset_names, :component_names, to: :config

  before_validation :set_realpath

  def set_realpath
    self.realpath ||= Pathname.new(path).realpath.to_s
  end

  # This only applies to Component, ComponentDir and Asset
  def make_asset
    payload = yaml_payload.merge(parent: self).merge(owner_hash(self))
    # binding.pry
    update(asset: asset_class.create(payload))
    asset_log('Created asset:', payload)
  rescue ActiveModel::UnknownAttributeError, ActiveRecord::AssociationTypeMismatch, ActiveRecord::RecordInvalid => e
    # binding.pry
    Cnfs.logger.warn(e.message, payload)
    asset_log('Error creating asset:', payload)
  end

  def owner_hash(obj)
    parent.owner_hash(obj)
  end

  # AssetGroup, Asset and Component (ComponentDir sort of)
  def yaml_payload
    @yaml_payload ||= yaml.merge!('name' => node_name)
  end

  def yaml
    @yaml ||= YAML.load_file(rootpath) || {}
  end

  def asset_class
    @asset_class ||= s_asset_type(node_name, pathname).classify.constantize
  end

  def load_search_paths
    return unless asset.respond_to?(:search_config)
    return unless (search_path = asset.search_config[:path])
    return unless search_path.directory? && search_path.exist?

    node_config = NodeConfig.create(asset.search_config)
    # node_config.pry
    nodes.create(path: search_path.to_s, config: node_config, type: 'Node::SearchPath', calc_type: calc_type)
  end

  def load_path
    pathname.each_child do |c_pathname|
      c_node_name = c_pathname.basename.to_s.delete_suffix(c_pathname.extname)
      c_asset_type = s_asset_type(c_node_name, c_pathname, 1)
      c_node_type = s_node_type(c_asset_type, c_pathname)
      c_node_type = "node/#{c_node_type}".classify
      _n = nodes.create(path: c_pathname.to_s, config: config, type: c_node_type, calc_type: c_asset_type)
      # binding.pry
    end
  end

  def s_asset_type(c_node_name, c_pathname, level = 0)
    if asset_names.include?(c_node_name) # resources, backend/resources.yml
      c_node_name
    elsif c_pathname.file? && asset_names.include?(parent.calc_type) # backend/resources/bucket.yml
      parent.calc_type.singularize
    else # backend, backend.yml, backend/development, backend/development.yml
      component_names[dir_level + level]
    end
  end

  def s_node_type(c_asset_type, c_pathname)
    if component_names.include?(c_asset_type)
      c_pathname.directory? ? :component_dir : :component
    elsif c_pathname.directory?
      :asset_dir
    else
      c_asset_type.pluralize.eql?(c_asset_type) ? :asset_group : :asset
    end
  end

  def node_name
    pathname.basename.to_s.delete_suffix(pathname.extname)
  end

  def dir_level
    @dir_level ||= pathname.sub(config.path, '').to_s.count('/')
  end

  def pathname
    @pathname ||= Pathname.new(path)
  end

  def rootpath
    @rootpath ||= Pathname.new(realpath)
  end

  def asset_log(title, yaml_payload)
    Cnfs.logger.debug(
      "#{title} node_name: #{node_name} calc_type: #{calc_type}\npathname: #{pathname}\n#{yaml_payload}"
    )
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :parent
        t.references :asset, polymorphic: true
        t.references :config
        t.string :path
        t.string :realpath
        t.string :calc_type
        t.string :type
      end
    end
  end
end
