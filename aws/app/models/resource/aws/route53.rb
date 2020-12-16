# frozen_string_literal: true

class Resource::Aws::Route53 < Resource::Aws
  store :config, accessors: %i[azs], coder: YAML

  class Zone
    attr_accessor :name, :id, :resource_record_sets, :client

    def initialize(name:, id:, client:)
      @name = name
      @id = id
      @client = client
    end

    def resource_record_sets
      @resource_record_sets ||= @client.list_resource_record_sets(hosted_zone_id: id).resource_record_sets
    end
  end

  def hosted_zones
    @hosted_zones ||= list_hosted_zones.hosted_zones.each_with_object([]) do |zone, ary|
      ary.append(Zone.new(name: zone.name, id: zone.id, client: client))
    end
  end

  def list_hosted_zones
    @list_hosted_zones ||= client.list_hosted_zones
  end

  # def client
  #   require 'aws-sdk-route53'
  #   config = provider.client_config(:route53)
  #   Aws::Route53::Client.new(config)
  # end
end
