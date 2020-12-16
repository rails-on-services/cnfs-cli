# frozen_string_literal: true
# See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Redshift/Client.html

class Resource::Aws::Redshift < Resource::Aws
  store :config, accessors: %i[node_type], coder: YAML

  # TODO: Move prompt stuff to a controller
  def configure
    self.node_type = prompt.enum_select('Node type:', instance_types, per_page: instance_types.size)
  end

  def instance_types
    @types ||= offers.select { |offer| offer.start_with?(selected_family) }.sort
  end

  def selected_family
    @selected_family ||= prompt.enum_select('Instance family:', offers_by_family, per_page: offers_by_family.size)
  end

  def offers_by_family
    @offers_by_family ||= offers.map { |offer| offer.split('.').shift }.uniq.sort
  end
  
  def offers
    @offers ||= client.describe_reserved_node_offerings.reserved_node_offerings.map { |offer| offer.node_type }
  end

  # def client
  #   require 'aws-sdk-redshift'
  #   config = provider.client_config(:redshift)
  #   Aws::Redshift::Client.new(config)
  # end
end
