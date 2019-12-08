# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :application_layers
  has_many :layers, through: :application_layers
  has_many :services, through: :layers
  belongs_to :environment

  # store :resources, accessors: %i[buckets cdns endpoints], coder: YAML

  # If there are environment classes, e.g. for DNS
  # those could be where the methods go
  # NOTE: The dns domain and domain slug comes from the target
  def buckets; options_hash(:buckets) end
  def cdns; options_hash(:cdns) end
  def endpoints; options_hash(:endpoints) end
end
