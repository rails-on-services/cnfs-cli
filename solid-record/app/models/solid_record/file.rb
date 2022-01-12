# frozen_string_literal: true

module SolidRecord
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
