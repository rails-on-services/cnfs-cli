# frozen_string_literal: true

class Aws::Resource::S3 < Aws::Resource
  delegate :list_buckets, to: :client

  # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#list_objects_v2-instance_method
  def list_objects(**params) = client.list_objects_v2(**params)
end
