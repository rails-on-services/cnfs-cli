# frozen_string_literal: true

class SegmentRoot < Component
  def owner_extension_path() = Cnfs.config.paths.segments

  # Override superclass methods as this is the root class in the hierarchy
  def key() = @key ||= super || warn_key

  def key_name() = name

  def key_name_env() = 'CNFS_KEY'

  def warn_key
    Cnfs.logger.error("No encryption key found. Run 'cnfs project generate_key'")
    nil
  end

  def cache_file() = @cache_file ||= "#{cache_path}.yml"

  def data_file() = @data_file ||= "#{data_path}.yml"

  def cache_path() = @cache_path ||= Cnfs.config.cache_home.join(name)

  def data_path() = @data_path ||= Cnfs.config.data_home.join(name)

  def attrs() = @attrs ||= [name]

  def struct() = OpenStruct.new(segment_type: 'root', name: name)

  def name() = Cnfs.application.name

  class << self
    def load
      Node.with_asset_callbacks_disabled do
        # Node::Component.create(path: segment_file_path, owner_class: self)
        Node.source = :p_node
        DefinitionDirectory.create(path: Cnfs.config.paths.definitions, autoload: true).create_stuff

        # Create Manually b/c it is a unique class
        file = SegmentFile.create(path: Cnfs.config.root.join('config/segments.yml'))
        root = create(file.content.merge(p_parent_id: file.id))

        SegmentDirectory.create(path: Cnfs.config.paths.segments, autoload: true).create_stuff(owner: root)
        # PNode::Directory.first.create_stuff(owner: root)
      end

      Cnfs::Core.model_names.each do |model|
        klass = model.classify.constantize
        klass.after_node_load if klass.respond_to?(:after_node_load)
      end
    rescue ActiveRecord::SubclassNotFound => e
      binding.pry
      Cnfs.logger.fatal(e.message.split('.').first.to_s)
      raise Cnfs::Error, ''
    end

    def segment_file_path() = Cnfs.config.root.join('config/segments.yml')
  end
end
