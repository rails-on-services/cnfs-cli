# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :provider
  belongs_to :runtime
  has_many :deployment_targets
  has_many :deployments, through: :deployment_targets
  has_many :target_layers
  has_many :layers, through: :target_layers
  has_many :services, through: :layers

  # store :environment, accessors: %i[dns], coder: YAML

  def dns; options_hash(:dns) end
  def globalaccelerator; options_hash(:globalaccelerator) end
  def kubernetes; options_hash(:kubernetes) end
  def postgres; options_hash(:postgres) end
  def redis; options_hash(:redis) end
  def vpc; options_hash(:vpc) end

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
    @domain_slug ||= domain.gsub('.', '-')
  end

  def domain
    @domain ||= [dns.sub_domain, dns.root_domain].compact.join('.')
  end
end
