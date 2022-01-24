# frozen_string_literal: true

class Aws::Resource::EC2 < Aws::Resource
  def instance_types(family) = instance_types_list(family).map { |offer| offer.split('.').last }.sort

  def instance_types_list(family)
    instance_type_offerings.select { |offer| offer.split('.').first.eql?(family.to_s) }
  end

  def offers_by_family
    @offers_by_family ||= instance_type_offerings.map { |offer| offer.split('.').first }.uniq.sort
  end

  def instance_type_offerings
    @instance_type_offerings ||= client.describe_instance_type_offerings[0].map(&:instance_type)
  end

  def describe_images(owners:, filters:)
    client.describe_images(owners: owners, filters: filters).images
  end
end
