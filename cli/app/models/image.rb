# frozen_string_literal: true

class Image < ApplicationRecord
  include Concerns::Asset

  belongs_to :builder
  belongs_to :registry
  belongs_to :repository

  store :build, coder: YAML # accessors: %i[args dockerfile tag]

  serialize :test_commands, Array

  class << self
    def add_columns(t)
      t.references :builder
      t.string :builder_name
      t.references :registry
      t.string :registry_name
      t.references :repository
      t.string :repository_name
      t.string :test_commands
      t.string :build
      # t.string :path
    end
  end
end
