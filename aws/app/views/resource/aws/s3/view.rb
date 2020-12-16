# frozen_string_literal: true

class Resource::Aws::S3::View < BaseView
  attr_accessor :model

  def render(model)
    @model = model
    blueprint = model.blueprint
    provider = blueprint.provider
    model.provider = provider

    if yes?('Create a new bucket?')
      model.name = ask('Budket name:', value: "#{blueprint.name}-#{random_string}")
    else
      model.name = enum_select('Bucket name:', list_buckets.map(&:name), per_page: list_buckets.size)
    end
  end

  def list_buckets
    @list_buckets ||= client.list_buckets.buckets
  end

  # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#list_objects_v2-instance_method
  def list_objects(params = {})
    client.list_objects_v2(params)
  end

  def client; model.client end
end
