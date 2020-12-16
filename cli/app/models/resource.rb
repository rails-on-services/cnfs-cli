# frozen_string_literal: true

class Resource < ApplicationRecord
  include Taggable

  # belongs_to :environment
  belongs_to :blueprint
  # belongs_to :provider
  # belongs_to :runtime

  store :config, accessors: %i[version], coder: YAML

  delegate :environment, to: :blueprint
  delegate :services, to: :environment

  parse_sources :project, :user
  parse_scopes :environment

  def to_hcl
    Hcl.new(as_hcl).render.join("\n")
  end

  def as_hcl
    # attributes.except('blueprint_id', 'id', 'config', 'environment', 'provider_id', 'runtime_id', 'type')
    attributes.except('id', 'config', 'environment', 'provider_id', 'runtime_id', 'type')
  end

  def as_save
    attributes.except('blueprint_id', 'id').merge({
      blueprint: blueprint&.name
    })
  end

  def resource_name
    self.class.name.demodulize
  end

  def file_path
    Cnfs.project.paths.config.join('environments', environment.name, "#{self.class.table_name}.yml")
  end

  class << self
		def create_table(s)
			s.create_table :resources, force: true do |t|
				# t.references :environment
				t.references :blueprint
				# t.references :provider
				# t.references :runtime
				t.string :stuff
				t.string :config
				# t.string :envs
				t.string :name
				t.string :tags
				t.string :type
			end
		end
  end
end
