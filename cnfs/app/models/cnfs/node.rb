# frozen_string_literal: true

module Cnfs
  class Node < ApplicationRecord
    self.table_name = 'cnfs/nodes'

    belongs_to :parent, class_name: 'Cnfs::Node'

    store :config, coder: YAML

    def bname() = pathname.basename.to_s

    def pathname() = @pathname ||= Pathname.new(path)

    def self.create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :parent
        t.string :path
        t.string :type
        t.string :config
      end
    end
  end

  class Directory < Node
    has_many :directories, foreign_key: 'parent_id', class_name: 'Cnfs::Directory', dependent: :destroy
    has_many :files, foreign_key: 'parent_id', class_name: 'Cnfs::File', dependent: :destroy

    delegate :rmtree, to: :pathname, prefix: :pathname

    store :config, accessors: %i[pattern]

    after_create :load_children
    after_destroy :pathname_rmtree

    def mkpath(name)
      dir = directories.create(path: pathname.join(name), pattern: pattern)
      pathname.join(name).mkpath
    end

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

    def file_type(_child) = 'Cnfs::File'

    # TODO: Move the TTY stuff to a controller and just return the hash
    def to_tree() = puts(TTY::Tree.new({ '.' => as_tree }).render)

    def as_tree
      directories.each_with_object(files.map{ |f| f.bname }) do |dir, ary|
        value = dir.pathname.children.size.zero? ? dir.bname : { dir.bname => dir.as_tree }
        ary.append(value)
      end
    end
  end

  class File < Node
    delegate :delete, to: :pathname, prefix: :pathname

    after_destroy :pathname_delete

    def file_content() = @file_content ||= read

    def read() = send("#{parser}_read")

    def write(content)
      send("#{parser}_write", content)
      @file_content = read
    end

    def parser() = parser_mapping[extension.to_sym] || :raw

    def parser_mapping
      {
        yml: :yaml,
        yaml: :yaml
      }
    end

    def shortname() = bname.delete_suffix(".#{extension}")

    def extension() = bname.split('.').last

    def raw_read() = pathname.read

    def yaml_read() = YAML.load_file(pathname)

    def yaml_write(content) = pathname.write(content.to_yaml)
  end
end
