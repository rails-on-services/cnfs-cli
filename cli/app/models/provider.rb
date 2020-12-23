# frozen_string_literal: true

class Provider < ApplicationRecord
  include Concerns::BelongsToProject

  belongs_to :project

  # store :config, accessors: %i[tf_version], coder: YAML

  parse_sources :project, :user

  def as_save
    attributes.except('id', 'name', 'project_id')
  end

  class << self
    def create_table(schema)
      schema.create_table :providers, force: true do |t|
        t.references :project
        t.string :config # client configuration details to be used as a hash to initialize SDK clients
        # t.string :envs
        t.string :name
        # t.string :tags
        t.string :type
      end
    end
  end
end
