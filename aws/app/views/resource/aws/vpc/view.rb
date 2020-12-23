# frozen_string_literal: true

class Resource::Aws::Vpc::View < BaseView
  attr_accessor :model, :region

  def render(model)
    @model = model
    blueprint = model.blueprint
    provider = blueprint.provider
    model.provider = provider

    # @region = enum_select('Region:', regions, per_page: regions.size)
    # model.region = region
    model.azs = multi_select('Availabiity Zones:', available_azs) do |menu|
      # menu.default 1, 3
    end
  end

  def available_azs
    # @azs ||= client(region: region).describe_availability_zones[0].map { |z| z.zone_name }
    @azs ||= client.describe_availability_zones[0].map { |z| z.zone_name }
  end

  # TODO: Move to provider view
  # def regions
  #   @regions ||= client.describe_regions[0].map { |r| r.region_name }.sort
  # end

  def client; model.client end
end
