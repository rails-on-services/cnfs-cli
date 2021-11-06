# frozen_string_literal: true

class Environment < ApplicationRecord
  include Concerns::Asset
  # include Concerns::Key

  store :values, coder: YAML

  class << self
    def add_columns(t)
      # t.string :key
      t.string :values
    end
  end

  # store :config, accessors: %i[domain], coder: YAML
  # store :config, accessors: %i[dns_sub_domain mount root_domain_managed_in_route53 lb_dns_hostnames], coder: YAML

  # def to_env
  #  infra_env = { platform: { infra: { provider: provider_type_to_s } } }
  #  Config::Options.new.merge_many!(infra_env, environment, provider.environment, namespace&.environment || {}).to_hash
  # end

  # TODO: Maybe this goes into a concern that can be included in component or other
  # def domain_slug
  #   @domain_slug ||= domain_name.gsub('.', '-')
  # end

  # def domain_name
  #   @domain ||= [dns_sub_domain, dns_root_domain].compact.join('.')
  # end
end
