# frozen_string_literal: true

module SolidRecord
  class File < Path
    store :config, accessors: %i[content_format]

    delegate :delete, to: :pathname, prefix: true

    before_validation :set_defaults

    after_create :create_association

    after_commit :pathname_delete, on: :destroy, if: -> { pathname.exist? }

    def set_defaults
      self.content_format ||= :plural
      self.model_class_name ||= name
    end

    def create_association = create_segment(Association, root: self, values: values)

    def flag(flag_type) = update(flags: flags << flag_type) # Called by Element

    # as_json strips Ruby object annotations
    # NOTE: #to_solid comes from segments.first
    def write = segments.count.zero? ? destroy : send("write_#{doc_type}".to_sym, segments.first.to_solid.as_json)

    def values = @values ||= content_format.eql?(:singular) ? { pathname.name => read } : read

    def read = send("read_#{doc_type}".to_sym)

    # Return a type based on the file's extension, e.g. .yml or .yaml returns :yaml
    def doc_type = document_map || raise(StandardError, "File type for #{pathname.extension} not found")

    def document_map = @document_map ||= SolidRecord.document_map[pathname.extension]

    def read_yaml = YAML.load_file(path) || {}

    def write_yaml(content) = pathname.write(content.to_yaml)

    def tree_label = "#{pathname.basename} (#{type.demodulize})"
  end

  def self.document_map = @document_map ||= config.document_map.transform_keys(&:to_s)
end
