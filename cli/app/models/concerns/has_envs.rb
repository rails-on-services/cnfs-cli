# frozen_string_literal: true

module Concerns
  module HasEnvs
    extend ActiveSupport::Concern

    included do
      store :envs, coder: YAML
    end

    class_methods do
      def add_columns(t)
        t.string :envs
      end
    end

    # TODO: Should this be what is called by the runtime generators?
    # TODO Are env_scopes needed?
    # env_scope is ignored; implemented to maintain compatibility with service model
    def to_env(env = nil, _env_scope = nil)
      all = envs[:all] || {}
      env = (envs[env] || {}).merge(all)
      env.empty? ? nil : Config::Options.new.merge!(env)
    end
  end
end
