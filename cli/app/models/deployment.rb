# frozen_string_literal: true

class Deployment < ApplicationRecord
  belongs_to :application
  belongs_to :target
  belongs_to :key

  has_many :assets, as: :owner

  store :config, accessors: %i[base_path], coder: YAML
  store :service_environments, accessors: %i[path], coder: YAML

  validates :base_path, presence: true
  validates :name, presence: true

  # Combine application, target and deployment environments into one config
  # which can be converted into an array of env values
  def to_env
    Config::Options.new.merge_many!(application.to_env, target.to_env, environment)
  end
end
