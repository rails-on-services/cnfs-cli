# frozen_string_literal: true

class Environment < ApplicationRecord
  include BelongsToProject

  belongs_to :builder
  belongs_to :key
  belongs_to :provider
  belongs_to :runtime

  has_many :blueprints
  has_many :namespaces
  has_many :services, through: :namespaces

  delegate :encrypt, :decrypt, to: :key

  store :config, accessors: %i[dns_sub_domain mount root_domain_managed_in_route53 lb_dns_hostnames], coder: YAML
  store :config, accessors: %i[application_environment]
  store :tf_config, accessors: %i[tags], coder: YAML

  # validates :runtime, presence: true
  # validates :provider, presence: true

  after_initialize do
    self.lb_dns_hostnames ||= []
  end

  # Default intitialze of target is to do nothing
  def init(options); end

  # def to_env
  #   infra_env = { platform: { infra: { provider: provider_type_to_s } } }
  #   Config::Options.new.merge_many!(infra_env, environment, provider.environment, namespace&.environment || {}).to_hash
  # end

  def provider_type_to_s
    provider.type.demodulize.underscore
  end

  def domain_slug
    @domain_slug ||= domain_name.gsub('.', '-')
  end

  def domain_name
    @domain ||= [dns_sub_domain, dns_root_domain].compact.join('.')
  end

  class << self
    def parse
      output = environments.each_with_object({}) do |e, h|
        env = e.split.last.to_s
        env_file = "config/environments/#{env}.yml"
        yaml = File.exist?(env_file) ? YAML.load_file(env_file) : {}
        h[env] = { name: env, project: 'app' }.merge(yaml)
      end
      write_fixture(output)
    end
  end
end
