# frozen_string_literal: true

module SolidRecord
  class FileMany < File
    def values() = @values ||= read
  end
end
