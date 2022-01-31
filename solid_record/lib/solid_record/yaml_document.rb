# frozen_string_literal: true

module SolidRecord
  class YamlDocument < Document
    def read() = YAML.load_file(path) || {}

    def write(content = nil)
      pathname.write(content.to_yaml) if content
    end
  end
end
