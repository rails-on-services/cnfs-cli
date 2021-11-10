# frozen_string_literal: true

class Dependency < ApplicationRecord
  include Concerns::Asset

  store :config, accessors: %i[linux mac]

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :config
        # t.string :runtime_name
        # t.references :runtime
      end
    end
  end
end
