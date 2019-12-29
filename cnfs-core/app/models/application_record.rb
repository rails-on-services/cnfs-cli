# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Used to generate environment values within context of target
  attr_accessor :target

  store :environment, coder: YAML

  # Provides a default empty hash to validate against
  # Override in model to validate against a specific schema
  def self.schema; {} end

  # pass in a schema or uses the class default schema
  # usage: validator.valid?(payload hash)
  # See: https://github.com/davishmcclurg/json_schemer
  def validator(schema = self.class.schema); JSONSchemer.schema(schema) end

  def to_env(env = nil, env_scope = :self) # , target = nil)
    # @target = target if target

    all = environment.dig(:all, env_scope) || {}
    env = (environment.dig(env, env_scope) || {}).merge(all)
    env.empty? ? nil : Config::Options.new.merge!(env)
  end
end
