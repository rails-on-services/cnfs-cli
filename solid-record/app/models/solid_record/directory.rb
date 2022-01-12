# frozen_string_literal: true

module SolidRecord
  class Directory < Node
    has_many :directories, foreign_key: 'parent_id', class_name: 'SolidRecord::Directory', dependent: :destroy
    has_many :files, foreign_key: 'parent_id', class_name: 'SolidRecord::File', dependent: :destroy

    delegate :rmtree, to: :pathname, prefix: :pathname

    store :config, accessors: %i[pattern]

    after_create :load_children
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
