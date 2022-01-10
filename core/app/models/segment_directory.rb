# frozen_string_literal: true

Cnfs::Node.all

class DefinitionDirectory < Cnfs::Directory
  def create_stuff
    files.each { |file| Definition.create(path: file.path) }
    directories.each(&:create_stuff)
  end
end

class SegmentDirectory < Cnfs::Directory
  def file_type() = 'SegmentFile'

  def create_stuff(owner:)
    files.select{ |f| f.content }.each { |file| file.send("create_#{file.stack_type}", owner: owner) }

    directories.each do |dir|
      file = files.select{ |f| f.shortname.eql?(dir.name) }.first
      # TODO: If a segment dir exists but not the file then create the File object (but not the actual file)
      # The Segment is also created. If the user updates the segment then the file will get written
      owner = file.segment if file

      dir.create_stuff(owner: owner)
    end
  end
end

class SegmentFile < Cnfs::File
  store :config, accessors: :segment

  def create_segment(owner:)
    update(segment: Component.create(content.merge(name: shortname, owner: owner, p_parent_id: id)))
  end

  def create_asset(owner:)
    asset_content.each do |name, values|
      asset_type = asset_names.include?(shortname) ? shortname : parent.name
      unless (klass = asset_type.to_s.classify.safe_constantize)
        Cnfs.logger.warn("Error on #{asset_type}")
        next
      end

      # TODO: Log it if not valid like it is today
      c = klass.create(values.merge(name: name, owner: owner, p_parent_id: id))
      # binding.pry unless c.persisted?
    end
  end

  def write_plural(child)
    all_models_for_this_file = child.class.where(p_parent_id: child.p_parent_id)
  end

  def asset_content() = mode.eql?(:plural) ? content : { shortname => content }

  def mode() = asset_names.include?(shortname) ? :plural : :singular

  def stack_type() = asset_names.include?(shortname) || asset_names.include?(parent&.name) ? :asset : :segment

  def asset_names() = Cnfs.config.asset_names
end
