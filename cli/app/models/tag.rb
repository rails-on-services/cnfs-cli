# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :resource_tags
  has_many :resources, through: :resource_tags
  has_many :service_tags
  has_many :services, through: :service_tags

  def entities
    resources + services
  end

  def config
    YAML.safe_load(self[:config] || '') || {}
  end
end
