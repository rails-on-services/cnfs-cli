# frozen_string_literal: true

module Cnfs
  class Node < ApplicationRecord
    self.table_name = 'cnfs/nodes'
    belongs_to :parent, class_name: 'Cnfs::Node'

    # NOTE: Do not delegate :parent to :pathname; That is the name of the self referencing association
    delegate :exist?, :basename, :join, to: :pathname

    store :config, coder: YAML

    def name() = pathname.basename.to_s

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
    has_many :directories, foreign_key: 'parent_id', class_name: 'Cnfs::Directory'
    has_many :files, foreign_key: 'parent_id', class_name: 'Cnfs::File'

    after_create :load_children, if: -> { autoload }

    delegate :children, :glob, to: :pathname

    attr_accessor :pattern, :autoload

    # TODO: Should file, directory or both provide the API for file operations?
    def rmdir
      # rmtree
      # files.destroy
      # directories.destroy
    end

    def mkpath(name)
      dir = directories.create(path: join(name), pattern: pattern, autoload: autoload)
      join(name).mkpath
    end

    # Or tell the file to create with content adn give it a directory as the parent
    #
    def mkfile(content)
    end

    def load_children
      files_to_load.each { |childpath| files.append(File.create(path: childpath, type: file_type)) }
      dirs_to_load.each do |childpath|
        directories.append(self.class.create(path: childpath, pattern: pattern, autoload: autoload))
      end
      true
    end

    def dirs_to_load() = children.select(&:directory?)

    def files_to_load() = pattern ? glob(pattern) : children.select(&:file?)

    def file_type() = nil

    def to_tree() = puts(TTY::Tree.new({ '.' => as_tree }).render)

    def as_tree
      directories.each_with_object(files.map{ |f| f.name }) do |dir, ary|
        value = dir.children.size.zero? ? dir.name : { dir.name => dir.as_tree }
        ary.append(value)
      end
    end
  end

  class File < Node
    def content() = @content ||= read

    def read() = send("#{parser}_read")

    def write(content) = send("#{parser}_write", content)

    def parser() = parser_mapping[extension.to_sym] || :raw

    def parser_mapping
      {
        yml: :yaml,
        yaml: :yaml
      }
    end

    def shortname() = pathname.basename.to_s.delete_suffix(".#{extension}")

    def extension() = pathname.basename.to_s.split('.').last

    def raw_read() = pathname.read

    def yaml_read() = YAML.load_file(pathname)

    def yaml_write(content) = YAML.load_file(pathname)
  end
end
