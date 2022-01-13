# frozen_string_literal: true

require 'active_record'
require 'pathname'
require 'sqlite3'

require_relative 'ext/pathname'

require_relative 'solid_record/version'
require_relative 'solid_record/data_store'
require_relative 'solid_record/path_map'

require_relative '../app/models/solid_record/table'
require_relative '../app/models/solid_record/persistence'
require_relative '../app/models/solid_record/associations'
require_relative '../app/models/solid_record/model'

# require_relative '../app/models/solid_record/directory'
# require_relative '../app/models/solid_record/file'

# Simple Usage:
#   SolidRecord.configure.load
#
# Usage:
#   SolidRecord.configure(schema_paths: 'app/models')
#   SolidRecord.path_maps += SolidRecord::PathMap.new(path: 'spec/dummy/data', map: { '.' => 'segments' })
#   SolidRecord.load

module SolidRecord
  class << self
    def load
      [DataStore, PathMap].each(&:load)
      true
    end

    def parser() = nil

    def parser_map
      {
        yml: :yaml,
        yaml: :yaml
      }
    end
  end

  class Error < StandardError; end
end
