# frozen_string_literal: true

class Aws::Resource::Route53::View < ResourceView
  attr_accessor :model, :region

  def render(model)
    @model = model
    blueprint = model.blueprint
    provider = blueprint.provider
    model.provider = provider

    zones = hosted_zones.map(&:name)
    model.zone = enum_select('Zone:', zones, per_page: zones.size)
  end

  class Zone
    attr_accessor :name, :id, :client
    attr_writer :resource_record_sets

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

  def client() = model.client
end
