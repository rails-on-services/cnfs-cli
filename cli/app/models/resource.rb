# frozen_string_literal: true

class Resource < ApplicationRecord
  include Concerns::Asset
  include Concerns::HasEnvs
  include Concerns::Taggable

  belongs_to :provider, optional: true
  belongs_to :provisioner, optional: true
  belongs_to :runtime, optional: true

  store :config, accessors: %i[source version], coder: YAML

  # NOTE: used in TF templates
  def module_name
    resource_name.underscore
  end

  def except_json
    super + %w[provider_id provisioner_id runtime_id]
  end

  # The fields that the builder should output upon creating the resource
  def outputs
    []
  end

  def to_hcl
    as_hcl.to_hcl.join("\n")
  end

  def as_hcl
    as_json.merge(config_as_hcl).except(*except_hcl)
  end

  def except_hcl
    %w[provisioner_name provider_name runtime_name config envs type]
  end

  def config_as_hcl
    self.class.stored_attributes[:config].each_with_object({}) do |accessor, hash|
      hash[accessor.to_s] = send(accessor)
    end
  end

  # From Aws::Resource::RDS to RDS
  def service_name
    self.class.name.demodulize
  end

  class << self
    def update_nils
      %w[provider provisioner]
    end

    def add_columns(t)
      t.string :provider_name
      t.references :provider
      t.string :provisioner_name
      t.references :provisioner
      t.string :runtime_name
      t.references :runtime
      # t.references :blueprint
      super
    end
  end
end
