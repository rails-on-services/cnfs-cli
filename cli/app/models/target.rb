# frozen_string_literal: true

class Target < ApplicationRecord
  has_many :deployments
  has_many :applications, through: :deployments

  has_many :target_services
  has_many :services, through: :target_services
  has_many :service_tags, through: :services, source: :tags

  has_many :target_resources
  has_many :resources, through: :target_resources
  has_many :resource_tags, through: :resources, source: :tags

  belongs_to :provider
  belongs_to :runtime
  belongs_to :infra_runtime, class_name: 'Runtime'


  # Used by controllers to set the deployment when running a command
  # Set by controler#configure_target
  attr_accessor :deployment, :application

  store :config, accessors: %i[dns_root_domain dns_sub_domain mount root_domain_managed_in_route53 lb_dns_hostnames], coder: YAML
  store :config, accessors: %i[application_environment]
  store :tf_config, accessors: %i[tags], coder: YAML

  validates :runtime, presence: true
  validates :provider, presence: true

  # Default intitialze of target is to do nothing
  def init(options); end

  def to_env
    a = {
      platform: {
        infra: {
          provider: provider_type_to_s,
          clients: provider.clients
        }
      }
    }
    b = Config::Options.new.merge!(environment).to_hash
    c = Config::Options.new.merge!(provider.environment).to_hash
    Config::Options.new.merge!(a).merge!(b).merge!(c).to_hash
  end

  def provider_type_to_s
    provider.type.demodulize.underscore
  end

  def write_path(type = :deployment)
    Pathname.new([deployment.base_path, path_for(type), "#{name}_#{application.name}"].join('/'))
  end

  def exec_path; File.expand_path(application.path || '.') end

  def path_for(type)
    case type
    when :deployment
      'cache/deployment'
    when :infra
      'data/infra'
    when :runtime
      'runtime'
    end
  end

  def domain_slug
    @domain_slug ||= domain_name.gsub('.', '-')
  end

  def domain_name
    @domain ||= [dns_sub_domain, dns_root_domain].compact.join('.')
  end
end
