# frozen_string_literal: true

class Provider::Aws < Provider
  store :config, accessors: %i[account_id profile access_key_id secret_access_key region], coder: YAML

  def credentials
    {
      access_key_id: Cnfs::Core.decrypt(access_key_id),
      secret_access_key: Cnfs::Core.decrypt(secret_access_key)
    }
  end

  def mq; super.merge(credentials).compact end

  def profile; super || 'default' end

  def region; super || 'us-east-1' end

  def storage; super.merge(credentials).compact end

  def resource_to_template(res)
    return res.template || res.name unless (type = res.type)
    key = type.demodulize.underscore.to_sym
    {
      bucket: :s3,
      cdn: :cloudfront,
      cert: :acm,
      dns: :route53,
      redis: 'elasticache-redis'
    }[key] || key
  end
end
