# frozen_string_literal: true

class Service < ApplicationRecord
  has_many :service_tags
  has_many :tags, through: :service_tags

  # store :config, accessors: %i[path], coder: YAML

  def test_commands(options = nil); [] end

  # Called by RuntimeGenerator#service_environment
  def to_env(target = nil)
    @target = target
    env = Config::Options.new.merge!(environment)
    if (deployment_env = target.deployment.service_environments[self.name])
      env.merge!(Config::Options.new.merge!(deployment_env).to_hash)
    end
    env.empty? ? nil : env
  end
end
