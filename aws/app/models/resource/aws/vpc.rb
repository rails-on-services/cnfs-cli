# frozen_string_literal: true

class Resource::Aws::Vpc < Resource::Aws
  store :config, accessors: %i[azs cidr enable_nat_gateway
    enable_vpn_gateway private_subnets public_subnets], coder: YAML

  def source
    super || 'terraform-aws-modules/vpc/aws'
  end

  def version
    super || '~> 2.64.0'
  end

  # NOTE: this is used by ruby aws sdk client to figure out the client class name
  def service_name
    'EC2'
  end
end
