# frozen_string_literal: true
# See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Redshift/Client.html

class Aws::Resource::Redshift < Aws::Resource
  def instance_types(family)
    @types ||= offers.select { |offer| offer.start_with?(_family) }.sort
  end

  def offers_by_family
    @offers_by_family ||= offers.map { |offer| offer.split('.').shift }.uniq.sort
  end
  
  def offers
    @offers ||= client.describe_reserved_node_offerings.reserved_node_offerings.map { |offer| offer.node_type }
  end
end
