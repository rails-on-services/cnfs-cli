# frozen_string_literal: true

class Service < ApplicationRecord
  has_many :service_tags
  has_many :tags, through: :service_tags

  def test_commands(options = nil); [] end

  def to_env(env = nil, env_scope = :self)
    all = environment.dig(:all, env_scope) || {}
    env = (environment.dig(env, env_scope) || {}).merge(all)
    env.empty? ? nil : Config::Options.new.merge!(env)
  end
end
