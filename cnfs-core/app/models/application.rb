# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :application_layers
  has_many :layers, through: :application_layers
  has_many :services, through: :layers
  has_many :resources, through: :layers
  # belongs_to :environment

  store :config, accessors: %i[secret_key_base rails_master_key jwt_encryption_key], coder: YAML

  def partition_name # called by CredentialsController
    environment.self.platform.partition_name
  end
end
