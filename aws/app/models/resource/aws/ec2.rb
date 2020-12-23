# frozen_string_literal: true

class Resource::Aws::EC2 < Resource::Aws
  store :config, accessors: %i[family size instance_count ami key_name monitoring
  vpc_security_group_ids subnet_id subnet_ids], coder: YAML
  store :envs, accessors: %i[public_ip], coder: YAML

  def source
    super || 'terraform-aws-modules/ec2-instance/aws'
  end

  def instance_type
    [family, size].join('.')
  end

  def as_hcl
    super.except(:family, :size).merge(instance_type: instance_type)
  end

  def shell
    system("ssh -A admin@#{public_ip}")
  end
end
