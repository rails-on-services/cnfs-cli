# frozen_string_literal: true

class Resource < ApplicationRecord
  include Concerns::Asset
  include Concerns::HasEnvs
  include Concerns::Taggable

  belongs_to :blueprint, optional: true
  belongs_to :provider, optional: true
  belongs_to :provisioner, optional: true

  store :config, accessors: %i[source version], coder: YAML

  class << self
    def add_columns(t)
      t.references :blueprint
      t.string :blueprint_name
      t.string :provider_name
      t.references :provider
      t.string :provisioner_name
      t.references :provisioner
      t.string :runtime_name
      t.references :runtime
    end
  end
end
