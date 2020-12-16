# frozen_string_literal: true

class Builder < ApplicationRecord
  include Concerns::BuilderRuntime

  parse_scopes :config
  parse_sources :cli

  def self.create_table(s)
    s.create_table :builders, force: true do |t|
      t.references :project
      t.string :config
      t.string :environment
      t.string :name
      t.string :tags
      t.string :type
    end
  end
end
