# frozen_string_literal: true

class Aws::Resource::EC2 < Aws::Resource
  def instance_types(family)
    instance_type_offerings.select do |offer|
      offer.split('.').first.eql?(family.to_s)
    end.map { |offer| offer.split('.').last }.sort
  end

  def offers_by_family
    @offers_by_family ||= instance_type_offerings.map { |offer| offer.split('.').first }.uniq.sort
  end

  def instance_type_offerings
    @instance_type_offerings ||= client.describe_instance_type_offerings[0].map { |offer| offer.instance_type }
  end

  def describe_images(owners:, filters:)
    client.describe_images(owners: owners, filters: filters).images
  end
end
