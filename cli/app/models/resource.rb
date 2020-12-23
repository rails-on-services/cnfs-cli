# frozen_string_literal: true

class Resource < ApplicationRecord
  include Concerns::Taggable

  belongs_to :blueprint

  store :config, accessors: %i[source version], coder: YAML

  delegate :environment, to: :blueprint
  delegate :services, to: :environment

  parse_sources :project, :user
  parse_scopes :environment

  # NOTE: used in TF templates
  def module_name
    resource_name.underscore
  end

  def to_hcl
    as_hcl.to_hcl.join("\n")
  end

  def as_hcl
    attributes.except('blueprint_id', 'config', 'envs', 'id', 'type').merge(config_as_hcl)
  end

  def config_as_hcl
    self.class.stored_attributes[:config].each_with_object({}) do |accessor, hash|
      hash[accessor] = send(accessor)
    end
  end

  def as_save
    attributes.except('blueprint_id', 'id').merge(blueprint: blueprint&.name)
  end

  # From Resource::Aws::RDS to RDS
  def service_name
    self.class.name.demodulize
  end

  def file_path
    Cnfs.project.paths.config.join('environments', environment.name, "#{self.class.table_name}.yml")
  end

  class << self
    def parse
      # key: 'environments/staging/resources.yml'
      super do |key, output, _opts|
        env = key.split('/')[1]
        output.each do |_key, value|
          value['blueprint'] = "#{env}_#{value['blueprint']}"
        end
      end
    end

    def create_table(schema)
      schema.create_table :resources, force: true do |t|
        t.references :blueprint
        t.string :config
        t.string :envs
        t.string :name
        t.string :tags
        t.string :type
      end
    end
  end
end
