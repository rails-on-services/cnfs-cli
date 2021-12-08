# frozen_string_literal: true

class Resource < ApplicationRecord
  include Concerns::Asset

  # attr_obj :config, :envs

  belongs_to :plan, optional: true
  belongs_to :provider, optional: true
  belongs_to :runtime, optional: true
  # belongs_to :provisioner, optional: true

  # store :config, accessors: %i[source version], coder: YAML

  # store :envs, coder: YAML

  class << self
    def add_columns(t)
      t.references :plan
      t.string :plan_name
      t.references :provider
      t.string :provider_name
      # t.references :provisioner
      # t.string :provisioner_name
      t.references :runtime
      t.string :runtime_name
      # t.string :envs
    end
  end
end
