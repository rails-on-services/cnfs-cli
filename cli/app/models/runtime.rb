# frozen_string_literal: true

class Runtime < ApplicationRecord
  include Concerns::Asset
  # include Concerns::BuilderRuntime

  store :config, accessors: %i[version], coder: YAML

  def self.add_columns(t)
    t.references :resource
    t.string :dependencies
    t.string :type
    t.string :tags
  end
end
