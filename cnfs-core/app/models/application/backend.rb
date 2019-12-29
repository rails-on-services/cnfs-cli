# frozen_string_literal: true

class Application::Backend < Application
  store :config, accessors: %i[secret_key_base rails_master_key jwt_encryption_key], coder: YAML

  def partition_name # called by CredentialsController
    environment.self.platform.partition_name
  end

  # Called by RuntimeGenerator
  def to_env(target)
    env = environment.self.merge!(platform: { jwt: jwt(target) }).merge!(other_stuff)
    env.merge!(target.provider.credentials) if target.provider.credentials
    env
  end

  def some
    application.environment.self.secret_key_base = Cnfs::Core.decrypt(application.secret_key_base)
    application.environment.self.rails_master_key = Cnfs::Core.decrypt(application.rails_master_key)
    application.environment.self.platform.jwt = Config::Options.new.merge!(jwt)
    application.environment.self.platform.infra = Config::Options.new.merge!(platform_infra)
  end


  def jwt(target)
    jwt = {
      aud: "https://api.#{target.domain_name}",
      iss: "https://iam.api.#{target.domain_name}"
    }
    jwt.merge!(environment.dig(:self, :platform, :jwt) || {})
    jwt.merge!(encryption_key: Cnfs::Core.decrypt(jwt_encryption_key))
  end

  def other_stuff
    {
      bucket_endpoint_url: 'http://localstack:4572',
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
