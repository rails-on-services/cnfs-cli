# frozen_string_literal: true

class Aws::Resource::EKS::Cluster < Aws::Resource::EKS
  store :config, accessors: %i[name tags], coder: YAML
  store :config, accessors: %i[aws_profile admins worker_groups worker_groups_launch_template services], coder: YAML

  def kubectl_context(target)
    "arn:aws:eks:#{region}:#{account_id}:cluster/#{target.cluster_name.cnfs_sub}"
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # NOTE: This will work with a cluster on any target since the provider instance, ie credentials, is per target
  def init_cluster(target, options)
    credentials_file = "#{Dir.home}/.aws/credentials"

    unless File.exist?(credentials_file) || ENV['AWS_ACCESS_KEY_ID']
      STDOUT.puts "missing #{credentials_file}"
      return
    end

    cmd_string = "aws eks update-kubeconfig --name #{target.cluster_name.cnfs_sub}"
    cmd_string = "#{cmd_string} --profile #{ENV['AWS_PROFILE']}" if ENV['AWS_PROFILE']

    # environment variable should be in higher priority than config
    # if infra.config.cluster.aws_profile && ! ENV['AWS_PROFILE'] && ! ENV['AWS_ACCESS_KEY_ID']
    #   cmd_string = "#{cmd_string} --profile #{infra.config.cluster.aws_profile}"
    # end

    # role_name = controller.options.role_name || provider.cluster.role_name
    if options.long || target.role_name
      cmd_string = "#{cmd_string} --role-arn arn:aws:iam::#{account_id}:role/#{target.role_name}"
    end
    binding.pry
    cmd_string
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # def client
  #   require 'aws-sdk-eks'
  #   config = provider.client_config(:eks)
  #   Aws::EKS::Client.new(config)
  # end
end

# frozen_string_literal: true

# class Target::Kubernetes < Target
#   store :config, accessors: %i[role_name cluster_name], coder: YAML
# 
#   validates :role_name, presence: true
#   validates :cluster_name, presence: true
# 
#   def role_name
#     super.cnfs_sub
#   end
# 
#   def init(options)
#     provider.init_cluster(self, options)
#   end
# end
