# frozen_string_literal: true

class Provider::Aws < Provider
  store :config, accessors: %i[access_key_id account_id region secret_acccess_key s3 sqs], coder: YAML

  def client_config(resource_type)
    config.slice(:access_key_id, :secret_access_key, :region).merge(config[resource_type] || {})
  end

  def resource_to_terraform_template_map
    {
      object_storage: :s3,
      cdn: :cloudfront,
      cert: :acm,
      dns: :route53,
      redis: 'elasticache-redis'
    }
  end
end
