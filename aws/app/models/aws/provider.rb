# frozen_string_literal: true

class Aws::Provider < Provider
  store :config, accessors: %i[access_key_id account_id region secret_acccess_key s3 sqs], coder: YAML

  def client_config(resource_type)
    config.slice(:access_key_id, :secret_access_key, :region).merge(config[resource_type] || {})
  end

  # NOTE: For terraform
  def command_env
    { 'AWS_DEFAULT_REGION' => region }
  end

  def regions
    begin
      regions = client.describe_regions[0].map { |r| r.region_name }.sort
    rescue Aws::EC2::Errors::AuthFailure => e
      raise Cnfs::Error, e.message
    end
  end

  def client
    @client ||= Aws::Resource::EC2::Instance.client(self)
  end
end
