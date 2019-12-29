# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :application_services
  has_many :services, through: :application_services
  has_many :application_resources
  has_many :resources, through: :application_resources

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
end
