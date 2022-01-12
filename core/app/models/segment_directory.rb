# frozen_string_literal: true

Cnfs::Node.all

class DefinitionDirectory < Cnfs::Directory
  def file_type(_child) = 'DefinitionFile'

  def create_records
    files.each { |file| Definition.create(path: file.path) }
    directories.each(&:create_records)
  end
end

class DefinitionFile < Cnfs::File; end

class SegmentDirectory < Cnfs::Directory
  def file_type(child)
    asset_names = Cnfs.config.asset_names
    asset_names.include?(child.shortname) || asset_names.include?(child.parent&.bname) ? 'AssetFile' : 'SegmentFile'
  end

  def create_records(owner:)
    files.select{ |f| f.file_content }.each { |file| file.create_owner(owner) }

    directories.each do |dir|
      file = files.select{ |f| f.shortname.eql?(dir.bname) }.first
      file&.update(segment_dir: dir)
      # TODO: If a segment dir exists but not the file then create the File object (but not the actual file)
      # The Segment is also created. If the user updates the segment then the file will get written
      owner = file.segment if file

      dir.create_records(owner: owner)
    end
  end
end

class SegmentFile < Cnfs::File
  store :config, accessors: %i[segment segment_dir]

  def create_owner(owner)
    update(segment: Component.create(file_content.merge(name: shortname, owner: owner, node: self)))
  end

  def self.create_content(object:)
  end

  def update_content(object:) = write(object.name => owner.node_content)

  def destroy_content(object:)
    # pathname.delete
    destroy
    segment_dir.destroy
  end
end

class AssetFile < Cnfs::File
  def create_owner(owner)
    asset_content.each do |name, values|
      asset_type = singular? ? parent.bname : shortname
      unless (klass = asset_type.to_s.classify.safe_constantize)
        Cnfs.logger.warn('Error on', asset_type)
        next
      end

      # TODO: Log it if not valid like it is today
      c = klass.create(values.merge(name: name, owner: owner, node: self))
      # binding.pry unless c.persisted?
    end
  end

  def self.create_content(object:)
    parent_node = object.owner.node.segment_dir
    file_name = parent_node.pathname.join("#{object.class.table_name}.yml").to_s
    node = find_or_create_by(parent: parent_node, path: file_name)
    current_content = file_content || {}
    writable_content = current_content.merge(object.name => object.node_content).sort.to_h
    node.write(writable_content)
  end

  def update_content(object:)
    if singular?
      write(object.name => object.node_content)
    else
      write(file_content.merge(object.node_content))
    end
  end

  def destroy_content(object:)
    if singular? || file_content.keys.size.eql?(1)
      destroy
    else
      write(file_content.except(object.name))
    end
  end

  def asset_content() = singular? ? { shortname => file_content } : file_content

  def singular?() = asset_names.exclude?(shortname)

  # If the file is empty YAML returns false so override this to return an empty hash when file is empty
  def file_content() = super || {}

  def asset_names() = Cnfs.config.asset_names
end
