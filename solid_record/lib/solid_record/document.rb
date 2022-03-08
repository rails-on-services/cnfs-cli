# frozen_string_literal: true

module SolidRecord
  class << self
    def document_map
      {
        yml: :yaml,
        yaml: :yaml
      }
    end
  end

  class Document < Association
    include FileSystemElement

    before_validation :set_defaults
    delegate :delete, to: :pathname, prefix: true
    after_commit :pathname_delete, on: :destroy, if: -> { pathname.exist? }

    def set_defaults() = self.model_type ||= pathname.safe_constantize

    def document() = self # Override Element's delegation to parent as 'the buck stops here'

    def flag(flag_type) = update(flags: flags << flag_type) # Called by ModelElement

    # as_json strips Ruby object annotations
    def write() = elements.count.zero? ? destroy : send("write_#{doc_type}".to_sym, to_solid.as_json)

    def values() = @values ||= pathname.singular? ? { pathname.name => read } : read

    def read() = send("read_#{doc_type}".to_sym)

    # Return a type based on the file's extension, e.g. .yml or .yaml returns :yaml
    def doc_type() = document_map || raise(StandardError, "Document type for #{pathname.extension} not found")

    def document_map() = @document_map ||= SolidRecord.document_map.transform_keys(&:to_s)[pathname.extension]

    def read_yaml() = YAML.load_file(path) || {}

    def write_yaml(content) = pathname.write(content.to_yaml)

    def element_type() = 'SolidRecord::RootElement' # Used by Association when creating ModelElements
  end
end
