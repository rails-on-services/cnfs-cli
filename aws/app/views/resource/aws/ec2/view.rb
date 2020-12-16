# frozen_string_literal: true

class Resource::Aws::EC2::View < BaseView
  attr_accessor :model

  def render(model)
    @model = model
    blueprint = model.blueprint
    provider = blueprint.provider
    model.provider = provider

    model.instance_type = select('Instance type:', instance_types, per_page: instance_types.size, filter: true)
    model.name = ask('Instance name:', value: "#{blueprint.name}-#{random_string}")
    model.key_name = ask('Key pair:')
    model.eip = yes?('Attach an elastic IP?')
  end

  def instance_types
    @types ||= offers.select do |offer|
      offer.split('.').first.eql?(selected_family)
    end.map { |offer| offer.split('.').last }.sort
  end

  def selected_family
    # @selected_family ||= prompt.enum_select('Instance family:', offers_by_family, per_page: offers_by_family.size)
    @selected_family ||= select('Instance family:', offers_by_family, per_page: offers_by_family.size, filter: true)
  end

  def offers_by_family
    @offers_by_family ||= offers.map { |offer| offer.split('.').first }.uniq.sort
  end

  def offers
    @offers ||= client.describe_instance_type_offerings[0].map { |offer| offer.instance_type }
  end

  def client; model.client end
end
