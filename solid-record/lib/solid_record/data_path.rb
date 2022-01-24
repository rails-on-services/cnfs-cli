# frozen_string_literal: true

module SolidRecord
  class << self
    attr_writer :path_maps, :glob_pattern

    # array of PathMap classes
    def path_maps() = @path_maps ||= []

    def glob_pattern() = @glob_pattern ||= '*.yml'

    def load_path_maps() = path_maps.each(&:load)

    def document_map
      {
        yml: :yaml,
        yaml: :yaml
      }
    end
  end

  class DataPath < ActiveRecord::Base
    include SolidRecord::Table
    self.table_name_prefix = 'solid_record_'

    has_many :documents

    before_validation :set_defaults

    def set_defaults
      self.glob ||= SolidRecord.glob_pattern
      self.path_map ||= '.'
    end

    validates :path, presence: true

    validate :path_exists, if: -> { path }

    def path_exists() = Pathname.new(path).exist?

    def load
      return unless valid?

      SolidRecord.skip_model_callbacks do
        in_path { load_path(Pathname.new('.')) }
      end
    end

    def in_path(&block) = Dir.chdir(path, &block)

    def load_path(loadpath)
      # loadpath.glob(glob).each { |childpath| create_document(childpath) }
      loadpath.glob(glob).each do |childpath|
        documents.create(path: childpath, klass_type: model_class_type(childpath), type: doc_class(childpath))
      end
      loadpath.children.select(&:directory?).each { |childpath| load_path(childpath) }
    end

    # Return a subclass of Document based on the file's extension, e.g. .yml or .yaml returns a YamlDocument
    # based on the vlaues of the SolidRecord.document_map hash
    def doc_class(childpath)
      doc_type = document_map[childpath.extension]
      klass = "solid_record/#{doc_type}_document".classify.safe_constantize
      raise ArgumentError, "Document type #{doc_type} not found" unless doc_type && klass

      klass
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize

    # Return a class for a given Pathname based on a set of rules
    def model_class_type(childpath)
      klass = childpath.safe_constantize(namespace)
      klass ||= childpath.parent.safe_constantize(namespace)
      klass ||= childpath.matchpath(pathname_map)&.safe_constantize(namespace)
      klass ||= pathname_map.safe_constantize(namespace) if recurse

      binding.pry if namespace
      debug("#{childpath} resoloved to #{klass.name}") if klass
      raise ArgumentError, "Failed to resolve #{childpath} with path_map: #{path_map}" unless klass

      klass.name
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity

    def pathname() = @pathname ||= Pathname.new(path)

    def pathname_map() = @pathname_map ||= Pathname.new(path_map)

    def debug(msg) = msg

    def document_map() = @document_map ||= SolidRecord.document_map.with_indifferent_access

    # TODO: Move the TTY stuff to a controller and just return the hash
    # def to_tree() = puts(TTY::Tree.new({ '.' => as_tree }).render)

    # def as_tree
    #   directories.each_with_object(files.map(&:name)) do |dir, ary|
    #     value = dir.pathname.children.size.zero? ? dir.name : { dir.name => dir.as_tree }
    #     ary.append(value)
    #   end
    # end

    class << self
      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.string :namespace
          t.string :path
          t.string :path_map
          t.string :glob
          t.boolean :recurse
        end
      end
    end
  end
end
