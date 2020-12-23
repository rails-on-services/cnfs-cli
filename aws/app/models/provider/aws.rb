# frozen_string_literal: true

class Provider::Aws < Provider
  store :config, accessors: %i[access_key_id account_id region secret_acccess_key s3 sqs], coder: YAML

  def client_config(resource_type)
    config.slice(:access_key_id, :secret_access_key, :region).merge(config[resource_type] || {})
  end

  # NOTE: For terraform
  def command_env
    { 'AWS_DEFAULT_REGION' => region }
  end

  # NOTE: Code to configure the provider; may or may not be used in future
  #   begin
  #     regions = ec2_client.describe_regions[0].map { |r| r.region_name }.sort
  #     @region = prompt.enum_select('Region:', regions, per_page: regions.size)
  #   rescue Aws::EC2::Errors::AuthFailure => e
  #     raise Cnfs::Error, e.message
  #   end
end
