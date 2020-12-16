# frozen_string_literal: true

class Provider < ApplicationRecord
  include BelongsToProject

  belongs_to :project

  parse_sources :project, :user

  # store :config, accessors: %i[tf_version], coder: YAML

  class << self
    def create_table(s)
      s.create_table :providers, force: true do |t|
        t.references :project
        t.string :config # client configuration details to be used as a hash to initialize SDK clients
        t.string :environment
        t.string :name
        t.string :tags
        t.string :type
      end
    end
  end
end
