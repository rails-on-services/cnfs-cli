# frozen_string_literal: true

class Resource < ApplicationRecord
  include Concerns::Asset
  # include Concerns::HasEnvs
  # include Concerns::Taggable

  belongs_to :provider, optional: true
  belongs_to :runtime, optional: true

  store :config, accessors: %i[source version], coder: YAML

  class << self
    def after_node_load
      all.each do |res|
        next unless (rt = Runtime.find_by(name: res.runtime_name))

        res.update(runtime: rt)
      end
    end
  end

  # TODO:
  # Need a provider
  # runtime is now part of this model not delegated to blueprint
  # builder is from the project
  # delegate :builder, :environment, :provider, :runtime, to: :blueprint
  # delegate :services, to: :environment

  # parse_sources :project, :user
  # parse_scopes :environment

  # NOTE: used in TF templates
  def module_name
    resource_name.underscore
  end

  # The fields that the builder should output upon creating the resource
  def outputs
    []
  end

  def to_hcl
    as_hcl.to_hcl.join("\n")
  end

  def as_hcl
    attributes.except('blueprint_id', 'config', 'envs', 'id', 'type', 'owner_id', 'owner_type').merge(config_as_hcl)
  end

  def config_as_hcl
    self.class.stored_attributes[:config].each_with_object({}) do |accessor, hash|
      hash[accessor] = send(accessor)
    end
  end

  def as_save
    attributes.except('blueprint_id', 'id', 'name').merge(blueprint: blueprint&.name)
  end

  # From Resource::Aws::RDS to RDS
  def service_name
    self.class.name.demodulize
  end

  # def save_path
  #   Cnfs.project.paths.config.join('environments', environment.name, "#{self.class.table_name}.yml")
  # end

  class << self
    def add_columns(t)
      t.references :provider
      t.references :runtime
      t.string :runtime_name
      t.string :context
      # t.references :blueprint
      t.string :envs
      t.string :tags
      t.string :type
    end
  end
end
