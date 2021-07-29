# frozen_string_literal: true

class Provider < ApplicationRecord
  # include Concerns::BelongsToProject

  # belongs_to :project

  belongs_to :owner, polymorphic: true
  # store :config, accessors: %i[tf_version], coder: YAML

  parse_sources :project, :user

  def as_save
    attributes.except('id', 'name', 'project_id')
  end

  class << self
    def create_table(schema)
      schema.create_table :providers, force: true do |t|
        t.references :owner, polymorphic: true
        t.string :__source
        # t.references :project
        t.string :config # client configuration details to be used as a hash to initialize SDK clients
        # t.string :envs
        t.string :name
        # t.string :tags
        t.string :type
      end
    end
  end
end
