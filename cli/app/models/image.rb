# frozen_string_literal: true

class Image < ApplicationRecord
  include Concerns::Asset

  belongs_to :registry

  class << self
    def add_columns(t)
      t.string :registry_name
      t.references :registry
      t.string :dockerfile
      t.string :build
      # t.string :path
    end
  end
end
