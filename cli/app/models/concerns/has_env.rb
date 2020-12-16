# frozen_string_literal: true

module Concerns
  module HasEnv
    extend ActiveSupport::Concern

    included do
      store :envs, coder: YAML
    end

    # env_scope is ignored; implemented to maintain compatibility with service model
    def to_env(env = nil, _env_scope = nil)
      all = envs.dig(:all) || {}
      env = (envs.dig(env) || {}).merge(all)
      env.empty? ? nil : Config::Options.new.merge!(env)
    end
  end
end
