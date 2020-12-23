# frozen_string_literal: true

class Namespace < ApplicationRecord
  include Concerns::Key
  include Concerns::Taggable

  belongs_to :environment
  has_many :services

  validates :name, presence: true

  delegate :project, :runtime, to: :environment

  store :config, accessors: %i[main], coder: YAML

  parse_scopes :namespace
  parse_sources :project, :user
  parse_options fixture_name: :namespace

  # Override to provide a path alternative to config/table_name.yml
  def file_path
    Cnfs.project.paths.config.join('environments', environment.name, name, 'namespace.yml')
  end

  def user_file_path
    Cnfs.user_root.join(Cnfs.config.name, Cnfs.paths.config, 'environments', environment.name, name, 'namespace.yml')
  end

  def as_save
    attributes.slice('config', 'name', 'tags')
  end

  class << self
    def create_table(schema)
      schema.create_table :namespaces, force: true do |t|
        t.references :environment
        t.string :config
        t.string :environment
        t.string :key
        t.string :name
        t.string :tags
      end
    end
  end
end
