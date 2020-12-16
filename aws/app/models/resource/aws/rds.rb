# frozen_string_literal: true
# See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/RDS/Client.html

class Resource::Aws::RDS < Resource::Aws
  store :config, accessors: %i[db_instance_class], coder: YAML

  # TODO: Move prompt stuff to a controller
  def configure
    self.db_instance_class = prompt.enum_select('Instance class:', instance_types, per_page: instance_types.size)
    # resp = client.describe_reserved_db_instances({
    #   db_instance_class: "db.t2.micro", 
    #   duration: "1y", 
    #   multi_az: false, 
    #   offering_type: "No Upfront", 
    #   product_description: "mysql", 
    # })
  end

  def instance_types
    @types ||= offers.select { |offer| offer.start_with?(selected_family) }.sort
  end

  def selected_family
    @selected_family ||= prompt.enum_select('Instance family:', offers_by_family, per_page: offers_by_family.size)
  end

  def offers_by_family
    @offers_by_family ||= offers.map { |offer| offer.split('.').shift(2).join('.') }.uniq.sort
  end
  
  def offers
    @offers ||= client.describe_reserved_db_instances_offerings.
      reserved_db_instances_offerings.map { |offer| offer.db_instance_class }
  end

  # def client
  #   require 'aws-sdk-rds'
  #   config = provider.client_config(:rds)
  #   Aws::RDS::Client.new(config)
  # end
end
