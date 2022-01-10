# frozen_string_literal: true

class Aws::Resource::EC2::Instance < Aws::Resource::EC2
  # store :config, accessors: %i[family size instance_count ami key_name monitoring
                               # vpc_security_group_ids subnet_id subnet_ids]
  # store :config, accessors: %i[public_ip os_type arn]
  # store :envs, accessors: %i[public_ip os_type arn]

  belongs_to :runtime, optional: true

  def instance_id() = config[:id]

  def valid_types() =  super.merge(runtime: %w[Compose::Runtime Skaffold::Runtime])

  def describe() = @describe ||= describe_instances(instance_id).reservations.first.instances.first

  def describe_instances(*ids) = client.describe_instances(instance_ids: ids)

  def source() = super || 'terraform-aws-modules/ec2-instance/aws'

  def instance_type() = [family, size].join('.')

  # TODO: See if public_ip and os_type or ssh_user can be retrieved from aws ec2 client calls
  # def connect() = system("ssh -A #{ssh_user_map[os_type]}@#{describe.public_ip_address}")
  def console() = system("ssh -A #{connect_host}")

  def connect_host
    config[:public_ip] || describe.public_ip_address
  end

  def ssh_user_map
    {
      debian: :admin,
      ubuntu: :ubuntu
    }.with_indifferent_access
  end

  def method_missing(method, *args) = config[method]
end
