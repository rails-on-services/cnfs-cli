# frozen_string_literal: true

require 'active_record'
require 'pathname'
require 'sqlite3'

require_relative 'solid_record/version'
require_relative 'solid_record/data_store'
require_relative '../app/models/solid_record/node'
require_relative '../app/models/solid_record/directory'
require_relative '../app/models/solid_record/file'

module SolidRecord
  class Error < StandardError; end
  # Your code goes here...
end
