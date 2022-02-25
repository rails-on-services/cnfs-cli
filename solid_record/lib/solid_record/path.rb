# frozen_string_literal: true

module SolidRecord
  class << self
    attr_accessor :namespace

    attr_writer :glob_pattern

    def glob_pattern() = @glob_pattern ||= '*.yml'
  end

  class Path < Element
    include FileSystemElement

    attr_reader :unknown_document_types

    store :config, accessors: %i[glob namespace]

    before_validation :set_defaults

    after_create :create_documents_from_files
    after_create :create_paths_from_dirs, if: -> { owner }
    after_create :raise_or_warn_unknown_types, if: -> { unknown_document_types.any? && owner.nil? }
    after_create :create_documents_from_unknown_types, if: -> { unknown_document_types.any? && owner }

    delegate :children, :rmdir, to: :pathname
    after_commit :rmdir, on: :destroy

    def write() = elements.count.zero? ? destroy : nil

    def set_defaults
      @unknown_document_types ||= []
      self.glob ||= SolidRecord.glob_pattern
      self.namespace ||= SolidRecord.namespace
    end

    def create_documents_from_files
      pathname.glob(glob).each do |childpath|
        if model_type
          create_document(childpath, model_type.safe_constantize)
        elsif (klass = childpath.safe_constantize(namespace))
          create_document(childpath, klass)
        else
          unknown_document_types.append(childpath)
        end
      end
    end

    def create_paths_from_dirs # rubocop:disable Metrics/AbcSize
      owner.class.reflect_on_all_associations(:has_many).map(&:name).map(&:to_s).each do |assn_name|
        next unless (assnpath = pathname.join(assn_name)).exist?

        SolidRecord.raise_or_warn(StandardError.new("#{assnpath} found but not a directory")) unless assnpath.directory?

        elements.create(type: 'SolidRecord::Path', path: assnpath.to_s, glob: glob, namespace: namespace, owner: owner,
                        model_type: assn_name.classify)
      end
    end

    def raise_or_warn_unknown_types
      unknown_document_types.each do |childpath|
        SolidRecord.raise_or_warn(StandardError.new("Error resolving #{childpath} with namespace #{namespace}"))
      end
    end

    def create_documents_from_unknown_types
      klass = owner.class.respond_to?(:unknown_document_type) ? owner.class.unknown_document_type : owner.class
      klass = klass.to_s.classify
      unknown_document_types.each { |childpath| create_document(childpath, klass) }
    end

    def create_document(childpath, klass)
      SolidRecord.logger.debug { "#{childpath} resoloved to #{klass}" }
      elements.create(type: element_type, path: childpath.to_s, owner: owner, model_type: klass)
    end

    def element_type() = 'SolidRecord::Document'

    def tree_label() = "#{name} (#{type.demodulize})"
  end
end
