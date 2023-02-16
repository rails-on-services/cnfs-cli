# frozen_string_literal: true

module SolidRecord
  class File < Path
    store :config, accessors: %i[content_format]

    delegate :delete, to: :pathname, prefix: true

    before_validation :set_defaults

    after_create :create_association

    after_commit :pathname_delete, on: :destroy, if: -> { pathname.exist? }

    def to_solid = segments.first.to_solid
    def to_solid_hash = segments.first.to_solid_hash
    def to_solid_array = segments.first.to_solid_array

    def set_defaults
      self.content_format ||= :plural
      self.model_class_name ||= name
    end

    def create_association
      assn = Association.create(create_hash(values: values))
      # binding.pry
      if assn.valid?
        segments << assn
      else
        SolidRecord.raise_or_warn(StandardError.new(assn.errors.full_messages.append(assn.to_json).join("\n").to_s))
      end
    end

    def document = self # Override Element's delegation to parent as 'the buck stops here'

    def flag(flag_type) = update(flags: flags << flag_type) # Called by Element

    # as_json strips Ruby object annotations
    # # TODO: to_solid needs to come from segments.first
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
