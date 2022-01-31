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

  class DocumentTypeError < StandardError; end

  class PathError < StandardError; end

  class DataPath < ActiveRecord::Base
    include SolidRecord::Table
    self.table_name_prefix = 'solid_record_'

    attr_accessor :owner

    has_many :documents
    has_many :elements, through: :documents

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

      SolidRecord.skip_solid_record_callbacks do
        in_path { load_path(Pathname.new('.'), owner) }
      end
    end

    def in_path(&block) = Dir.chdir(path, &block)

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity

    def load_path(loadpath, model)
      all_dirs = loadpath.children.select(&:directory?)
      singular_dirs = all_dirs.select(&:singular?).map(&:name)

      loadpath.glob(glob).each do |childpath|
        doc = documents.create(path: childpath, klass_type: model_class_type(childpath),
                               type: doc_class(childpath), model: model)
        next unless (dir = singular_dirs.delete(childpath.name))

        # If there is a directory of the same name as the document then load the directory with the model
        #   as the document's root_element's model
        load_path(loadpath.join(dir), doc.root_element.model)
      end
      # TODO: Singular directories that don't have a matching document?

      # Plural directories are loaded with the model as the current model
      all_dirs.select(&:plural?).each { |childpath| load_path(childpath, model) }
      self
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    # Return a subclass of Document based on the file's extension, e.g. .yml or .yaml returns a YamlDocument
    # based on the vlaues of the SolidRecord.document_map hash
    def doc_class(childpath)
      doc_type = document_map[childpath.extension]
      klass = "solid_record/#{doc_type}_document".classify.safe_constantize
      raise DocumentTypeError, "Document type #{doc_type} not found" unless doc_type && klass

      klass
    end

    # Return a class for a given Pathname based on a set of rules
    def model_class_type(childpath)
      klass = nil
      search = [childpath, childpath.parent, childpath.matchpath(pathname_map)]
      search.append(pathname_map) if recurse
      search.each { |c_path| break if (klass = c_path&.safe_constantize(namespace)) }

      if klass
        SolidRecord.logger.debug{ "#{childpath} resoloved to #{klass.name}" }
      else
        SolidRecord.logger.warn{ "Failed to resolve #{childpath} with path_map: #{path_map}" }
        # raise PathError, "Failed to resolve #{childpath} with path_map: #{path_map}" unless klass
      end
      klass.name
    end

    def pathname() = @pathname ||= Pathname.new(path)

    def pathname_map() = @pathname_map ||= Pathname.new(path_map)

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
