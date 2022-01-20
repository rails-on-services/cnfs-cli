# frozen_string_literal: true

module SolidRecord
  class YamlDocument < Document
    def content() = YAML.load_file(path) || {}

    def write(content = {}) = pathname.write(content.to_yaml)
  end
end
