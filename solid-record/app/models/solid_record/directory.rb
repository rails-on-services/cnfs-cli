# frozen_string_literal: true

module SolidRecord
  module Directory
    # has_many :directories, foreign_key: 'parent_id', class_name: 'SolidRecord::Directory', dependent: :destroy
    # has_many :files, foreign_key: 'parent_id', class_name: 'SolidRecord::File', dependent: :destroy

    delegate :rmtree, to: :pathname, prefix: :pathname

    # store :config, accessors: %i[pattern]

    # after_create :load_children
    after_destroy :pathname_rmtree

    # def mkpath(name)
    #   dir = directories.create(path: pathname.join(name), pattern: pattern)
    #   pathname.join(name).mkpath
    # end

    def load_children
      files_to_load.each do |childpath|
        child = File.new(path: childpath, parent: self)
        child.type = file_type(child)
        child.save
      end

      dirs_to_load.each do |childpath|
        directories << self.class.create(path: childpath, pattern: pattern)
      end

      true
    end

    def dirs_to_load() = pathname.children.select(&:directory?)

    def files_to_load() = pattern ? pathname.glob(pattern) : pathname.children.select(&:file?)

    def file_type(_child) = 'SolidRecord::File'

    # Create Models
    def create_records(owner:)
      files.select(&:file_content).each { |file| file.create_owner(owner) }

      directories.each do |dir|
        file = files.select { |f| f.shortname.eql?(dir.bname) }.first
        file&.update(segment_dir: dir)
        # TODO: If a segment dir exists but not the file then create the File object (but not the actual file)
        # The Segment is also created. If the user updates the segment then the file will get written
        owner = file.segment if file

        dir.create_records(owner: owner)
      end
    end

    # Persist Models

    # Output Display
    # TODO: Move the TTY stuff to a controller and just return the hash
    def to_tree() = puts(TTY::Tree.new({ '.' => as_tree }).render)

    def as_tree
      directories.each_with_object(files.map(&:bname)) do |dir, ary|
        value = dir.pathname.children.size.zero? ? dir.bname : { dir.bname => dir.as_tree }
        ary.append(value)
      end
    end
  end
end
