# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :provider
  belongs_to :runtime
  has_many :deployment_targets
  has_many :deployments, through: :deployment_targets
  has_many :target_layers
  has_many :layers, through: :target_layers
  has_many :services, through: :layers
  has_many :resources, through: :layers

  # Used by controllers to set the deployment when running a command
  # Set by controler#configure_target
  attr_accessor :deployment, :application

  store :config, accessors: %i[dns_root_domain dns_sub_domain mount root_domain_managed_in_route53 lb_dns_hostnames], coder: YAML

  delegate :version, to: :runtime

  def orchestrator; runtime.name end

  def provider_type_to_s
    provider.type.underscore.split('/').last
  end

  def write_path(type = :deployment)
    # Pathname.new([deployment.base_path, type, name, deployment.name].join('/'))
    Pathname.new([deployment.base_path, name, deployment.name, type].join('/'))
  end

  # def dns; options_hash(:dns) end
  # def globalaccelerator; options_hash(:globalaccelerator) end
  # def kubernetes; options_hash(:kubernetes) end
  # def postgres; options_hash(:postgres) end
  # def redis; options_hash(:redis) end
  # def vpc; options_hash(:vpc) end

  # def dns; @dns ||= Config::Options.new(YAML.load(self[:dns] || '')) end
  # def dns; @dns ||= defaults.dns.merge!(YAML.load(self[:dns] || '')) end
  # def storage; @storage ||= defaults.storage.merge!(Config::Options.new(YAML.load(self[:storage] || '')).to_hash) end
  # def cdns; @cdns ||= defaults.cdns.merge!(YAML.load(self[:cdns] || '')) end
  # def sub; ENV['SUB'] end

  # def hostnames
  #   dns.endpoints.keys.each_with_object([]) { |name, ary| ary << hostname(name) }
  # end

  # def hostname(endpoint)
  #   return unless values = dns.endpoints.dig(endpoint) || Config::Options.new(host: endpoint)
  #   scheme = values.scheme ? "#{values.scheme}://" : ''
  #   host = (sub_deploy and sub) ? "#{values.host}-#{sub}" : values.host
  #   URI("#{scheme}#{host}.#{domain}")
  # end

  # def distributions
  #   cdns.distributions.keys.each_with_object([]) { |name, ary| ary << distribution(name) }
  # end

  # def distribution(name)
  #   return unless values = cdns.distributions.dig(name) || Config::Options.new
  #   OpenStruct.new(bucket: values.bucket || "#{name}-#{domain_slug}",
  #                  uri: values.uri || URI("https://#{name}.#{domain}"))
  # end

  # def buckets
  #   storage.buckets.keys.each_with_object([]) { |name, ary| ary << bucket(name) }
  # end

  # def bucket(name)
  #   return unless values = storage.buckets.dig(name) || Config::Options.new
  #   ret_name = values.name || "#{name}-#{domain_slug}"
  #   OpenStruct.new(name: ret_name,
  #                  services: values.services || [],
  #                  path: (sub_deploy and sub) ? "#{ret_name}/#{sub}" : ret_name)
  # end

  def domain_slug
    @domain_slug ||= domain_name.gsub('.', '-')
  end

  def domain_name
    @domain ||= [dns_sub_domain, dns_root_domain].compact.join('.')
  end
end
