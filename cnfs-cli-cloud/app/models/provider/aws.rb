# frozen_string_literal: true

class Provider::Aws < Provider
  def credentials
    Config::Options.new({
      aws_access_key_id: aws_access_key_id,
      aws_secret_access_key: aws_secret_access_key,
    }).to_array
  end

  def aws_access_key_id; environment['aws_access_key_id'] || config['aws_access_key_id'] end
  def aws_secret_access_key; environment['aws_secret_access_key'] || config['aws_secret_access_key'] end
  def aws_region; environment['aws_region'] || config['aws_region'] end
  def aws_account_id; environment['aws_account_id'] || config['aws_account_id'] end

  def resource_to_terraform_template_map
    {
      object_storage: :s3,
      cdn: :cloudfront,
      cert: :acm,
      dns: :route53,
      redis: 'elasticache-redis'
    }
  end

  def kubectl_context(target)
    "arn:aws:eks:#{aws_region}:#{aws_account_id}:cluster/#{target.cluster_name.cnfs_sub}"
  end

  # NOTE: This will work with a cluster on any target since the provider instance, ie credentials, is per target
  def init_cluster(target, options)
    credentials_file = "#{Dir.home}/.aws/credentials"

    unless (File.exist?(credentials_file) or ENV['AWS_ACCESS_KEY_ID'])
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
    cmd_string = "#{cmd_string} --role-arn arn:aws:iam::#{account_id}:role/#{target.role_name}" if options.long || target.role_name
    binding.pry
    cmd_string
  end
end
