# frozen_string_literal: true

class Aws::Resource::EC2::Instance < Aws::Resource::EC2
  store :config, accessors: %i[family size instance_count ami key_name monitoring
                               vpc_security_group_ids subnet_id subnet_ids instance_id]
  store :envs, accessors: %i[public_ip os_type]

  belongs_to :runtime, optional: true

  def valid_types() =  super.merge(runtime: %w[Compose::Runtime Skaffold::Runtime])

  def describe() = @describe ||= describe_instances(instance_id).reservations.first.instances.first

  def describe_instances(*ids) = client.describe_instances(instance_ids: ids)

  def source() = super || 'terraform-aws-modules/ec2-instance/aws'

  def instance_type() = [family, size].join('.')

  # TODO: See if public_ip and os_type or ssh_user can be retrieved from aws ec2 client calls
  def shell() = system("ssh -A #{ssh_user_map[os_type]}@#{describe.public_ip_address}")

  def ssh_user_map
    {
      debian: :admin,
      ubuntu: :ubuntu
    }.with_indifferent_access
  end
end
