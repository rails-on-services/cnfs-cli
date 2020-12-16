# frozen_string_literal: true

class Blueprint < ApplicationRecord
  # include Concerns::HasEnv
  # include Taggable
  belongs_to :environment
  belongs_to :provider
  belongs_to :runtime
  has_many :resources

  delegate :project, to: :environment
  delegate :paths, to: :project

  parse_sources :project, :user
  parse_scopes :environment

  def resource_list
    []
  end

  def builder
    ::Builder.find_by(name: builder_name)
  end

  def builder_name
    # Blueprint::Aws::Terraform::Instance
    self.class.name.underscore.split('/')[2]
  end

  def as_save
    attributes.slice('config', 'envs', 'name', 'source', 'tags', 'type', 'version').merge({
      name: "#{environment&.name}_#{name}",
      environment: environment&.name,
      provider: provider&.name,
      runtime: runtime&.name
    })
  end

  def file_path
    paths.config.join('environments', environment.name, 'blueprints.yml')
  end

  class << self
    def create_table(s)
      s.create_table :blueprints, force: true do |t|
        # t.references :builder
        t.references :environment
        t.references :provider
        t.references :runtime
        t.string :config
        # t.string :envs
        t.string :name
        t.string :source
        # t.string :tags
        t.string :type
        t.string :version
      end
    end
  end
end
