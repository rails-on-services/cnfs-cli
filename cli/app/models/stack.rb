# frozen_string_literal: true

class Stack < ApplicationRecord
  # include Concerns::HasEnvs
  # include Concerns::BelongsToProject
  include Concerns::Component
  include Concerns::Key

  # parse_scopes :environment
  # parse_sources :project, :user
  # parse_options fixture_name: :stack

  belongs_to :owner, polymorphic: true

  # alias_method :owner, :project

  has_many :environments, as: :owner

  belongs_to :default_environment, optional: true, class_name: 'Environment'

  def as_save
    # attributes.slice('config', 'name', 'tags', 'type')
  end

  def user_save_path
    Cnfs.user_root.join(Cnfs.config.name, Cnfs.paths.config, 'environments', name, 'stacks.yml')
  end

  class << self
    def create_table(schema)
      schema.create_table :stacks, force: true do |t|
        # t.references :builder
        # t.references :project
        t.references :owner, polymorphic: true
        t.string :context
        t.string :config
        t.string :__source
        # t.string :dns_root_domain
        # t.string :envs
        t.string :key
        t.string :name
        # t.string :tags
        # t.string :tf_config
      end
    end
  end
end

