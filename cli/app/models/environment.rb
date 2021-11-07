# frozen_string_literal: true

class Environment < ApplicationRecord
  include Concerns::Asset
  after_initialize :do_it, if: proc { persisted? }

  def do_it
    values.keys.each do |key|
      define_singleton_method(key.to_sym) { values[key] }
      define_singleton_method("#{key}=".to_sym) { |name| values[key] = name }
    end
  end

  store :values, coder: YAML

  class << self
    def add_columns(t)
      t.string :values
    end
  end

  
  def yeah
    self.secret_key_base = encrypt(SecureRandom.hex(64))
    self.rails_master_key = encrypt(SecureRandom.hex)
    self.values['platform']['jwt']['encryption_key'] = encrypt(SecureRandom.hex)
    nil
  end

  def show
    puts as_json.to_yaml
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
