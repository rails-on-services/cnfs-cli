# frozen_string_literal: true

class Environment < ApplicationRecord
  include Concerns::Asset
  # include Concerns::Component
  # include Concerns::Key
  # include Concerns::HasEnvs

  # belongs_to :builder
  # belongs_to :owner, polymorphic: true

  # has_many :blueprints
  # has_many :resources, through: :blueprints
  # has_many :runtimes, through: :blueprints
  # def runtimes; [] end

  store :values, coder: YAML
  # store :config, accessors: %i[domain], coder: YAML
  # store :config, accessors: %i[dns_sub_domain mount root_domain_managed_in_route53 lb_dns_hostnames], coder: YAML
  # store :config, accessors: %i[application_environment]
  # store :tf_config, accessors: %i[tags], coder: YAML

  # validates :builder, presence: true
  # validate :no_duplicated_runtimes

  # def no_duplicated_runtimes
  #   def_runtimes = runtimes.pluck(:type)
  #   unique_runtimes = def_runtimes.dup.uniq!
  #   return if unique_runtimes.nil?
  #
  #   duplicate_runtimes = unique_runtimes.select { |e| def_runtimes.count(e) > 1 }
  #   errors.add(:runtimes, "Must be unique. Multiple resources with identical runtime #{duplicate_runtimes.join(', ')}")
  # end

  # Override to provide a path alternative to config/table_name.yml
  # def save_path
  #   Cnfs.project.paths.config.join('environments', name, 'environment.yml')
  # end

  # def user_save_path
  #   Cnfs.user_root.join(Cnfs.config.name, Cnfs.paths.config, 'environments', name, 'environment.yml')
  # end

  # Given a service, return the runtime that supports its type
  # def runtime_for(service)
  #   runtimes.select { |r| r.supported_service_types.include?(service.type) }.first
  # end

  # after_initialize do
  #   self.lb_dns_hostnames ||= []
  # end

  # Default intitialze of target is to do nothing
  # def init(options); end

  # def to_env
  #  infra_env = { platform: { infra: { provider: provider_type_to_s } } }
  #  Config::Options.new.merge_many!(infra_env, environment, provider.environment, namespace&.environment || {}).to_hash
  # end

  # def provider_type_to_s
  #   provider.type.demodulize.underscore
  # end

  # def domain_slug
  #   @domain_slug ||= domain_name.gsub('.', '-')
  # end

  # def domain_name
  #   @domain ||= [dns_sub_domain, dns_root_domain].compact.join('.')
  # end

  # def as_save
  #   attributes.slice('config', 'name', 'tags', 'type')
  # end

  class << self
    def add_columns(t)
      # t.string :context
      # t.string :key
      t.string :values
    end
  end
end
