# frozen_string_literal: true

class Provider::Aws < Provider
  store :config, accessors: %i[account_id profile access_key_id secret_access_key region], coder: YAML

  def credentials
    {
      access_key_id: access_key_id.plaintext(force: true),
      secret_access_key: secret_access_key.plaintext(force: true)
    }
  end

  def mq; super.merge(credentials).compact end

  def profile; super || 'default' end

  def region; super || 'us-east-1' end

  def storage; super.merge(credentials).compact end

  def resource_to_terraform_template_map
    {
      object_storage: :s3,
      cdn: :cloudfront,
      cert: :acm,
      dns: :route53,
      redis: 'elasticache-redis'
    }
  end

  # NOTE: This will work with a cluster on any target since the provider instance, ie credentials, is per target
  def init_cluster(target, options)
    credentials_file = "#{Dir.home}/.aws/credentials"

    unless (File.exist?(credentials_file) or ENV['AWS_ACCESS_KEY_ID'])
      STDOUT.puts "missing #{credentials_file}"
      return
    end

    cmd_string = "aws eks update-kubeconfig --name #{target.cluster_name}"
    cmd_string = "#{cmd_string} --profile #{ENV['AWS_PROFILE']}" if ENV['AWS_PROFILE']

    # environment variable should be in higher priority than config
    # if infra.config.cluster.aws_profile && ! ENV['AWS_PROFILE'] && ! ENV['AWS_ACCESS_KEY_ID']
    #   cmd_string = "#{cmd_string} --profile #{infra.config.cluster.aws_profile}"
    # end

    # role_name = controller.options.role_name || provider.cluster.role_name
    cmd_string = "#{cmd_string} --role-arn arn:aws:iam::#{account_id}:role/#{target.role_name}" if options.long || target.role_name
    cmd_string
  end
end
