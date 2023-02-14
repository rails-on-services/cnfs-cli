# frozen_string_literal: true

module SolidRecord
  class FileOne < File
    def values() = @values ||= { pathname.name => read }
  end
end
