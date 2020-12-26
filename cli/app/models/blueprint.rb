# frozen_string_literal: true

class Blueprint < ApplicationRecord
  # include Concerns::HasEnv
  # include Concerns::Taggable
  belongs_to :environment
  belongs_to :provider
  belongs_to :runtime
  has_many :resources

  delegate :project, to: :environment
  delegate :paths, :path, to: :project

  parse_sources :project, :user
  parse_scopes :environment

  # List of resource classes that are managed by this blueprint
  def resource_classes
    []
  end

  # Used by builder to set the template's context to this blueprint
  def _binding
    binding
  end

  def builder
    @builder ||= ::Builder.find_by(name: builder_name)
  end

  def builder_name
    # example: Blueprint::Aws::Terraform::Instance
    self.class.name.underscore.split('/')[2]
  end

  def as_save
    # attributes.slice('config', 'envs', 'tags', 'type').merge(
    attributes.slice('config', 'type').merge(
      {
        provider: provider&.name,
        runtime: runtime&.name
      }
    )
  end

  def file_path
    paths.config.join('environments', environment.name, 'blueprints.yml')
  end

  class << self
    def create_table(schema)
      schema.create_table :blueprints, force: true do |t|
        t.references :environment
        t.references :provider
        t.references :runtime
        t.string :config
        # t.string :envs
        t.string :name
        # t.string :tags
        t.string :type
      end
    end
  end
end
