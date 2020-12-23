# frozen_string_literal: true

class Resource::Aws::Route53::View < BaseView
  attr_accessor :model, :region

  def render(model)
    @model = model
    blueprint = model.blueprint
    provider = blueprint.provider
    model.provider = provider

    zones = hosted_zones.map {|zone| zone.name }
    model.zone = enum_select('Zone:', zones, per_page: zones.size)
    binding.pry
  end

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

  def client; model.client end
end
