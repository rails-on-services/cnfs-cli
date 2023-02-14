# frozen_string_literal: true

module SolidRecord
  class Dir < Path
    # TODO: Move any of this code to DirGeneric
    # TODO: Clean up the remainder of the code
    # TODO: Implement validations across all Dir classes

    # attr_reader :unknown_document_types

    store :config, accessors: %i[glob namespace]
    delegate :children, :rmdir, to: :pathname
    # delegate :singular?, :plural?, to: :pathname

    before_validation :set_defaults

    after_create :process_contents


    # TODO: move this to Path and do the following:
    # set.glob ||= parent&.glob || SolidRecord.config.glob
    # this will set glob on every Path as it moves down so src doesn't need to be invoked
    def set_defaults
      @unknown_document_types ||= []
      self.glob ||= SolidRecord.config.glob
      self.namespace ||= SolidRecord.config.namespace
      super
    end

    # def instances?() = content_type.to_s.eql?('instances')
    # def associations?() = content_type.to_s.eql?('associations')


    # after_create :create_documents_from_files
    # after_create :create_paths_from_dirs, if: -> { owner }
    # after_create :raise_or_warn_unknown_types, if: -> { unknown_document_types.any? && owner.nil? }
    # after_create :create_documents_from_unknown_types, if: -> { unknown_document_types.any? && owner }

    after_commit :rmdir, on: :destroy

    def write() = segments.count.zero? ? destroy : nil

    # def create_documents_from_files
    #   pathname.glob(glob).each do |childpath|
    #     if model_type
    #       create_document(childpath, model_type.safe_constantize)
    #     elsif (klass = childpath.safe_constantize(namespace))
    #       create_document(childpath, klass)
    #     else
    #       unknown_document_types.append(childpath)
    #     end
    #   end
    # end

    # def create_paths_from_dirs # rubocop:disable Metrics/AbcSize
    #   owner.class.reflect_on_all_associations(:has_many).map(&:name).map(&:to_s).each do |assn_name|
    #     next unless (assnpath = pathname.join(assn_name)).exist?

    #     SolidRecord.raise_or_warn(StandardError.new("#{assnpath} found but not a directory")) unless assnpath.directory?

    #     elements.create(type: 'SolidRecord::Dir', path: assnpath.to_s, glob: glob, namespace: namespace, owner: owner,
    #                     model_type: assn_name.classify)
    #   end
    # end

    # def raise_or_warn_unknown_types
    #   unknown_document_types.each do |childpath|
    #     SolidRecord.raise_or_warn(StandardError.new("Error resolving #{childpath} with namespace #{namespace}"))
    #   end
    # end

    # def create_documents_from_unknown_types
    #   klass = owner.class.respond_to?(:unknown_document_type) ? owner.class.unknown_document_type : owner.class
    #   klass = klass.to_s.classify
    #   unknown_document_types.each { |childpath| create_document(childpath, klass) }
    # end

    # def create_document(childpath, klass)
    #   SolidRecord.logger.debug { "#{childpath} resoloved to #{klass}" }
    #   elements.create(type: element_type, path: childpath.to_s, owner: owner, model_type: klass)
    # end

    # def element_type() = 'SolidRecord::Document'

    def tree_label() = "#{name} (#{type.demodulize} - #{content_type})"

    def invalid_path(path) = path.to_s.delete_prefix("#{src.pathname.parent.to_s}/")

    def msg(assn) = "is not a valid #{assn} association on #{owner.class.name}"
  end
end
