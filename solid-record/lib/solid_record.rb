# frozen_string_literal: true

require 'active_record'
require 'sqlite3'

require 'solid_support'

require_relative 'solid_record/version'
require_relative 'solid_record/lyric' if defined? Hendrix
require_relative 'solid_record/data_store'

require_relative 'solid_record/table'
require_relative 'solid_record/data_path'
require_relative 'solid_record/document'
require_relative 'solid_record/element'

require_relative 'solid_record/yaml_document'

require_relative 'solid_record/persistence'
require_relative 'solid_record/model'

# Usage:
#   SolidRecord.load
module SolidRecord
  class << self
    def load(**options)
      [DataStore, DataPath.create(**options)].each(&:load)
      true
    end
  end

  class Error < StandardError; end
end
