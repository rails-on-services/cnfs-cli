# frozen_string_literal: true

class ApplicationGenerator < GeneratorBase
  def env
    empty_directory(write_path)
    template('env.erb', "#{write_path}/app.env") unless environment.empty?
  end

  def layers
    application.layers.each do |layer|
      call(:layer, "#{write_path}/#{layer.name}", target, layer, :application)
    end
  end

  private

  def environment
    @environment ||= set_environment
  end

  def set_environment
    application.environment.self.merge!(other_stuff)
    set_provider_credentials
    application.environment.self.secret_key_base = Cnfs::Core.decrypt(application.secret_key_base)
    application.environment.self.rails_master_key = Cnfs::Core.decrypt(application.rails_master_key)
    application.environment.self.platform.jwt = Config::Options.new.merge!(jwt)
    application.environment.self.platform.infra = Config::Options.new.merge!(platform_infra)
    application.environment.self.merge!(target.provider.environment)
    application.environment.self.merge!(target.environment.application.to_hash) if target.environment.application
    target.services.map{ |s| s.environment.application }.compact.each do |env|
      application.environment.self.merge!(env.to_hash)
    end
    target.resources.map{ |s| s.environment.application }.compact.each do |env|
      application.environment.self.merge!(env.to_hash)
    end
    application.services.map{ |s| s.environment.application }.compact.each do |env|
      application.environment.self.merge!(env.to_hash)
    end
    application.resources.map{ |s| s.environment.application }.compact.each do |env|
      application.environment.self.merge!(env.to_hash)
    end
    application.environment.self
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

  def set_provider_credentials
    target.provider.credentials.each_pair do |key, value|
      application.environment.self[key] = Cnfs::Core.decrypt(value)
    end
  end

  def jwt
    jwt = {
      aud: "https://api.#{target.domain_name}",
      iss: "https://iam.api.#{target.domain_name}"
    }
    jwt.merge!(application.environment.dig(:self, :platform, :jwt) || {})
    jwt.merge!(encryption_key: Cnfs::Core.decrypt(application.jwt_encryption_key))
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
    application.resources.where(type: 'Resource::Cdn').each_with_object({}) do |cdn, hash|
      hash[cdn.name] = {
        bucket: cdn.bucket,
        enabled: true,
        url: "https://#{cdn.hostname}.#{target.domain_name}"
      }
    end
  end

  def storage_buckets
    application.resources.where(type: 'Resource::Bucket').pluck(:name).each_with_object({}) do |n, hash|
      hash[n] = target.provider.storage.except(:endpoint).merge({
        name: "#{n}-#{target.domain_slug}",
        provider: target.provider.type.underscore.split('/').last
      })
    end
  end

  def storage_services
    application.resources.where(type: 'Resource::Bucket').each_with_object({}) do |resource, hash|
      resource.services.each { |service| hash[service] = resource.name }
    end
  end
end
