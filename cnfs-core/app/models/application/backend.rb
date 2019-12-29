# frozen_string_literal: true

class Application::Backend < Application
  attr_accessor :target

  store :config, accessors: %i[platform endpoints secret_key_base rails_master_key], coder: YAML

  def partition_name # called by CredentialsController
    environment.self.platform.partition_name
  end

  # Called by RuntimeGenerator#application_environment
  def to_env(env_scope, target = nil)
    return super unless (@target = target)

    return unless (env = environment[env_scope])

    env.merge!(platform: { jwt: jwt })
    env.merge!(other_stuff)
    env.merge!(platform_infra)
  end

  def secret_key_base; super._cnfs_decrypt end
  def rails_master_key; super._cnfs_decrypt end

  def jwt
    return {} unless (hash = platform[:jwt])
    hash.each_pair do |key, value|
      value.gsub!('{domain}', target.domain_name)
      hash[key] = Cnfs::Core.decrypt(value) if value._cnfs_encrypted
    end
  end

  def other_stuff
    {
      bucket_endpoint_url: 'http://localstack:4572 # this comes from backend.rb',
      infra: { provider: 'aws' },
      platform: {
        api_docs: {
          server: { host: "https://api.development.demo.cnfs.io" }
        },
        postman: { workspace: 'api.development.demo.cnfs.io' },
        connection: { type: 'host' },
				external_connection_type: 'path',
				feature_set: 'mounted',
				hosts: 'api.development.demo.cnfs.io'
      }
    }
  end

  def platform_infra
    {
      provider: target.provider_type_to_s,
      resources: {
        cdns: cdns,
        storage: {
          buckets: storage_buckets,
          config: { region: 'ap-southeast-1' },
          services: storage_services
        }
      }
    }
  end

  def cdns
    resources.where(type: 'Resource::Cdn').each_with_object({}) do |cdn, hash|
      hash[cdn.name] = {
        bucket: cdn.bucket,
        enabled: true,
        url: "https://#{cdn.hostname}.#{target.domain_name}"
      }
    end
  end

  def storage_buckets
    resources.where(type: 'Resource::Bucket').pluck(:name).each_with_object({}) do |n, hash|
      hash[n] = target.provider.storage.except(:endpoint).merge({
        name: "#{n}-#{target.domain_slug}",
        provider: target.provider.type.underscore.split('/').last
      })
    end
  end

  def storage_services
    resources.where(type: 'Resource::Bucket').each_with_object({}) do |resource, hash|
      resource.services.each { |service| hash[service] = resource.name }
    end
  end
end
