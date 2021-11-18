# frozen_string_literal: true

class Aws::Resource::EC2::Instance < Aws::Resource::EC2
  store :config, accessors: %i[family size instance_count ami key_name monitoring
                               vpc_security_group_ids subnet_id subnet_ids instance_id], coder: YAML
  store :envs, accessors: %i[public_ip os_type], coder: YAML

  belongs_to :runtime, optional: true

  def valid_types
    super.merge(runtime: %w[Runtime::Compose Runtime::Skaffold])
  end

  def outputs
    %i[instance_id]
  end

  def describe
    @describe ||= describe_instances(instance_id).reservations.first.instances.first
  end

  def describe_instances(*ids)
    client.describe_instances(
      instance_ids: ids
    )
  end

  def source
    super || 'terraform-aws-modules/ec2-instance/aws'
  end

  def instance_type
    [family, size].join('.')
  end

  def as_hcl
    super.except(:family, :size).merge(instance_type: instance_type)
  end

  # TODO: See if public_ip and os_type or ssh_user can be retrieved from aws ec2 client calls
  def shell
    system("ssh -A #{ssh_user_map[os_type]}@#{describe.public_ip_address}")
  end

  def ssh_user_map
    {
      debian: :admin,
      ubuntu: :ubuntu
    }.with_indifferent_access
  end
end
