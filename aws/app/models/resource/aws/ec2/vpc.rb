# frozen_string_literal: true

class Resource::Aws::EC2::Vpc < Resource::Aws
  store :config, accessors: %i[azs cidr enable_nat_gateway
    enable_vpn_gateway private_subnets public_subnets], coder: YAML

  def source
    super || 'terraform-aws-modules/vpc/aws'
  end

  def version
    super || '~> 2.64.0'
  end

  def available_azs
    @azs ||= client.describe_availability_zones[0].map { |z| z.zone_name }
  end
end
