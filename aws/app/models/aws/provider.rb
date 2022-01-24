# frozen_string_literal: true

module Aws
  class Provider < OneStack::Provider
    # standard credentials for aws
    store :config, accessors: %i[account_id access_key_id secret_access_key region]

    # configuration values to add for a specific SDK client
    store :config, accessors: %i[s3 sqs]

    attr_encrypted :access_key_id, :secret_access_key

    def client_config(resource_type)
      config.slice(:access_key_id, :secret_access_key, :region).merge(config[resource_type] || {})
    end

    def regions
      client.describe_regions[0].map(&:region_name).sort
    rescue EC2::Errors::AuthFailure => e
      raise OneStack::Error, e.message
    end

    def client() = @client ||= Resource::EC2::Instance.client(self)

    # Terraform Provisioner
    store :config, accessors: %i[source version]

    def source() = super || 'hashicorp/aws'

    def as_terraform # rubocop:disable Metrics/MethodLength
      {
        terraform: {
          required_providers: {
            aws: {
              source: source,
              version: version
            }.compact
          }
        },
        provider: {
          aws: {
            region: region
          }
        }
      }
    end

    # Pulumi Provisioner
    def as_pulumi; end
  end
end
