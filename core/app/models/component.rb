# frozen_string_literal: true

class Component < ApplicationRecord
  include Concerns::Parent
  include Concerns::Extendable

  belongs_to :owner, class_name: 'Component'
  has_one :parent, as: :owner, class_name: 'Node'
  has_one :context

  has_many :components, foreign_key: 'owner_id'

  has_many :context_components
  has_many :contexts, through: :context_components

  store :default, coder: YAML, accessors: :segment_name

  # For every asset Companent has_many and an <asset_name>_name default stored_attribute
  Cnfs::Core.asset_names.each do |asset_name|
    has_many asset_name.to_sym, as: :owner

    store :default, accessors: "#{asset_name.singularize}_name".to_sym

    # Return array of names for each of the component's assets
    define_method("#{asset_name.singularize}_names") { send(asset_name.to_sym).pluck(:name) }
  end

  # if segments_type is not present then cannot search beyond this component
  # validates :segments_type, presence: true

  class << self
    def context_from(options)
      c_list = list(options)
      Context.find_or_create_by(component: c_list.last) do |context|
        context.options = options
        context.components << c_list.slice(0, c_list.size - 1)
      end
    end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  #
    # List hierarchy of components based on CLI options, cwd, ENV and default segment_name(s)
    def list(options)
      pwd = APP_CWD.relative_path_from(Cnfs.config.paths.segments).to_s.split('/').excluding('..')
      current = SegmentRoot.first
      components = [current]
      while current.components.any?
        next_segment = current.next_segment(options, pwd)
        break if next_segment.name.nil? # No search values found so stop at the current component

        unless next_segment.component
          Cnfs.logger.warn(current.segments_type&.capitalize, "'#{next_segment.name}' specified by",
                           "*#{next_segment.source}* not found.",
                           "Context set to #{current.owner&.segments_type} '#{current.name}'")
          break
        end

        current = next_segment.component
        components << current
      end
      components
    end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

    def structs(options) = list(options).each_with_object([]) { |comp, ary| ary.append(comp.struct) } 
  end

  def struct() = OpenStruct.new(segment_type: owner.segments_type, name: name, color: color)

  def next_segment(options, pwd = nil)
    next_name, next_source = next_segment_spec(options, pwd)
    OpenStruct.new(name: next_name, source: next_source, component: components.find_by(name: next_name))
  end

  # Returns an Array for the component's next segment based on priority
  # If a command line option was provided (e.g. -s stack_name) then return that
  # If an ENV was provided (e.g. CNFS_STACK) then return that
  # If the current component has an attribute 'default' then return that
  # Otherwise return an empty Array
  def next_segment_spec(options, pwd)
    if (name = options.fetch(segments_type, nil))
      [name, 'CLI option']
      # TODO: remove the lonely operator after dropping context
    elsif pwd&.any?
      [pwd.shift, 'cwd']
    elsif (name = Cnfs.config.segments[segments_type].try(:[], :env_value))
      [name, 'ENV value']
    elsif segment_name # default[:segment_name] in this component's yaml file
      [segment_name, parent.node_name]
    else
      []
    end
  end

  # Return the default dir_path of the parent's path + this component's name unless segment_path is configured
  # In which case parse segment_path to search the component hierarchy for the specified repository and blueprint
  def dir_path()
    # binding.pry
    if extension.nil?
      node_warn(node: parent, msg: "Extension '#{extension_name}' not found")
    elsif extension.segment(extension_path).nil?
      node_warn(node: parent, msg: "Extension '#{extension_name}' segment '#{extension_path}' not found")
    else
      return extension.segment(extension_path)
    end
    parent.parent.rootpath.join(parent.node_name).to_s
  end 

  def extension() = Cnfs.extensions[extension_name]

  def extension_name() = segment_path ? segment_path.split('/').first.to_sym : :application

  def extension_path() = segment_path ? segment_path.split('/')[1...]&.join('/') : owner_extension_path

  def owner_extension_path() = owner.extension_path.join(name)

  # Key search priorities:
  # 1. ENV var
  # 2. Project's data_path/keys.yml
  # 3. Owner's key
  def key() = @key ||= ENV[key_name_env] || local_file_read(path: keys_file).fetch(key_name, owner&.key)

  # 1_target/backend => 1_target_backend
  def key_name() = @key_name ||= "#{owner.key_name}_#{name}"

  # 1_target/backend => CNFS_KEY_BACKEND
  def key_name_env() = @key_name_env ||= "#{owner.key_name_env}_#{name.upcase}"

  def keys_file() = @keys_file ||= Cnfs.config.data_home.join('keys.yml')

  def generate_key
    key_file_values = local_file_read(path: keys_file).merge(new_key)
    local_file_write(path: keys_file, values: key_file_values)
  end

  def new_key() = { key_name => Lockbox.generate_key }

  # Read/Write 'runtime' component data to this file
  def cache_file() = @cache_file ||= "#{cache_path}.yml"

  # This component's local file to provide local overrides to project values, e.g. change default runtime_name
  # The user must maintain these files locally
  # These values are merged for runtime so they are not saved into the project's files
  def data_file() = @data_file ||= "#{data_path}.yml"

  # Operators and Context's Assets can read/write their 'runtime' data into this directory
  def cache_path() = @cache_path ||= owner.cache_path.join(name)

  # Child Components and Assets can read their local overrides into this directory
  def data_path() = @data_path ||= owner.data_path.join(name)

  def attrs() = @attrs ||= owner.attrs.dup.append(name)

  def tree_name
    bp_name = component_name.nil? ? '' : "  source: #{component_name.gsub('/', '-')}"
    "#{name} (#{owner.segments_type})#{bp_name}"
  end

  def as_merged() = as_json

  # Display components as a TreeView
  def to_tree() = puts('', as_tree.render)

  def as_tree
    require 'tty-tree'
    # TTY::Tree.new("#{name} (#{self.class.name.underscore})" => tree)
    TTY::Tree.new('.' => { segments_type&.pluralize || '.' => tree })
  end

  def segment_names() = @segment_names ||= components.pluck(:name)

  def color() = owner.segments_type ? Cnfs.config.segments[owner.segments_type].try(:[], :color) : nil

  def tree
    components.each_with_object([]) do |comp, ary|
      if comp.components.size.zero?
        ary.append(comp.name)
      else
        ary.append({ comp.name => { comp.segments_type&.pluralize => comp.tree } })
      end
    end
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :type           # The only subclass is SegmentRoot. Not to be configured by User
        t.string :segment_path   # Usually nil, but can be set to extension/segment_name
        t.string :segments_type  # corresponds to ENV and CLI options to filter the components to most specific
        t.string :default
        t.string :config
        t.references :owner
      end
    end
  end
end
