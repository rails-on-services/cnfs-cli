# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :key
  delegate :encrypt, :decrypt, to: :key

  # has_many :target_namespaces
  # has_many :namespaces, through: :target_namespaces
  # has_many :deployments, through: :namespaces
  # has_many :applications, through: :deployments

  # has_many :target_services
  # has_many :services, through: :target_services
  # has_many :service_tags, through: :services, source: :tags

  # has_many :target_resources
  # has_many :resources, through: :target_resources
  # has_many :resource_tags, through: :resources, source: :tags

  belongs_to :provider
  belongs_to :blueprint
  belongs_to :runtime
  belongs_to :infra_runtime, class_name: 'Runtime'

  # has_many :context_targets
  # has_many :contexts, through: :context_targets

  # Used by controllers to set the deployment when running a command
  # Set by controler#configure_target
  # attr_accessor :deployment, :application, :namespace
  attr_accessor :context

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

  # def exec_path
  #   # NOTE: if the context has not defined an application, e.g. cluster_admin#create
  #   File.expand_path(context.application&.path || '.')
  # end

  def domain_slug
    @domain_slug ||= domain_name.gsub('.', '-')
  end

  def domain_name
    @domain ||= [dns_sub_domain, dns_root_domain].compact.join('.')
  end
end
