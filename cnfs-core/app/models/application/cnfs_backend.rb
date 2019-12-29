# frozen_string_literal: true

class Application::CnfsBackend < Application
  store :config, accessors: %i[platform endpoints secret_key_base rails_master_key], coder: YAML

  def partition_name # called by CredentialsController
    environment.self.platform.partition_name
  end

  def image_prefix; config.dig(:image, :build_args, :rails_env) end

  # Called by RuntimeGenerator#application_environment
  def to_env(target = nil)
    @target = target

    all = environment.dig(:all) || {}
    env = (environment.dig(target.environment) || {}).merge(all)
    return if env.empty?

    env = Config::Options.new.merge!(env)
    env.merge!(extended_env)
    env.merge!(platform_env)
    env.merge!(services_env(self))
    env.merge!(services_env(target))
  end

  def secret_key_base; super._cnfs_decrypt end
  def rails_master_key; super._cnfs_decrypt end

  def services_env(owner)
    [owner.resources, owner.services].each_with_object(Config::Options.new) do |entities, env|
      entities.each do |entity|
        next unless (entity_env = entity.to_env(target.environment, :application))

        env.merge!(entity_env.to_hash)
      end
    end.to_hash
  end

  def extended_env
    {
      secret_key_base: secret_key_base,
      rails_master_key: rails_master_key
    }
  end

  def platform_env
    {
      platform: {
        infra: platform_infra,
        jwt: platform_jwt,
        connection: platform_connection,
        api_docs: api_docs
      }
    }
  end

  def platform_jwt
    return {} unless (hash = platform[:jwt])
    hash.each_pair do |key, value|
      value.gsub!('{domain}', target.domain_name)
      hash[key] = Cnfs::Core.decrypt(value) if value._cnfs_encrypted
    end
  end

  def api_docs
    {
      server: { host: "https://api.#{target.domain_name}" },
      postman: { workspace: "api.#{target.domain_name}" }
    }
  end

  # def old_docs
  #   {
  #     api_docs: {
  #       server: { host: "https://api.#{target.domain_name}" }
  #     },
  #     postman: { workspace: "api.#{target.domain_name}" }
  #   }
  # end
  # bucket_endpoint_url: 'http://localstack:4572 # this comes from backend.rb',
  # infra: { provider: 'aws' },

  def platform_connection
    {
      connection: { type: 'host' },
      external_connection_type: 'path',
      feature_set: 'mounted',
      hosts: "api.#{target.domain_name}"
    }
  end

  def platform_infra
    {
      provider: target.provider_type_to_s,
      resources: target.provider.resources
    }
  end

  # def old_one
  #   {{
  #       cdns: cdns,
  #       storage: {
  #         buckets: storage_buckets,
  #         config: { region: 'ap-southeast-1' },
  #         services: storage_services
  #       }
  #     }
  #   }
  # end

  # def cdns
  #   resources.where(type: 'Resource::Cdn').each_with_object({}) do |cdn, hash|
  #     hash[cdn.name] = {
  #       bucket: cdn.bucket,
  #       enabled: true,
  #       url: "https://#{cdn.hostname}.#{target.domain_name}"
  #     }
  #   end
  # end

  # def storage_buckets
  #   resources.where(type: 'Resource::Bucket').pluck(:name).each_with_object({}) do |n, hash|
  #     hash[n] = target.provider.storage.except(:endpoint).merge({
  #       name: "#{n}-#{target.domain_slug}",
  #       provider: target.provider.type.underscore.split('/').last
  #     })
  #   end
  # end

  # def storage_services
  #   resources.where(type: 'Resource::Bucket').each_with_object({}) do |resource, hash|
  #     resource.services.each { |service| hash[service] = resource.name }
  #   end
  # end
end
