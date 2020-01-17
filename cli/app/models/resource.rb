# frozen_string_literal: true

class Resource < ApplicationRecord
  has_many :resource_tags
  has_many :tags, through: :resource_tags

  store :config, accessors: %i[tf_version], coder: YAML

  def resources; YAML.load(self[:resources] || '') || {} end
end
