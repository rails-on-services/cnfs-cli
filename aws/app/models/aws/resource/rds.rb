# frozen_string_literal: true
# See: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/RDS/Client.html

class Aws::Resource::RDS < Aws::Resource
  def instance_types(family)
    reserved_db_instances_offerings.select { |offer| offer.start_with?(family) }.sort
  end

  def offers_by_family
    @offers_by_family ||= reserved_db_instances_offerings.map { |offer| offer[0...offer.rindex('.')] }.uniq.sort
  end
  
  def reserved_db_instances_offerings
    @reserved_db_instances_offerings ||= client.describe_reserved_db_instances_offerings.
      reserved_db_instances_offerings.map { |offer| offer.db_instance_class }
  end
end
