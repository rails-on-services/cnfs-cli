# frozen_string_literal: true

class Deployment < ApplicationRecord
  belongs_to :application
  belongs_to :target
  belongs_to :key

  store :config, accessors: %i[base_path], coder: YAML
  store :service_environments, accessors: %i[path], coder: YAML

  validates :base_path, presence: true
  validates :name, presence: true

  # Combine target environment, application environment and deployment into one config
  # which can be converted into an array of env values
  def to_env
    Config::Options.new.merge_many!(target.to_env, application.to_env, environment)
  end
end
