# frozen_string_literal: true

class Deployment < ApplicationRecord
  belongs_to :application
  belongs_to :target
  belongs_to :key

  store :config, accessors: %i[base_path], coder: YAML
  store :service_environments, accessors: %i[path], coder: YAML

  validates :base_path, presence: true
  validates :name, presence: true

  def to_env
    Config::Options.new.merge!(environment).to_hash
  end
end
