# frozen_string_literal: true

class Asset::Credential < Asset
  FIXED_FILE = 'application_default_credentials.json'

  # TODO: This needs to change and coordinate with following files:
  # https://github.com/rails-on-services/helm-charts/blob/master/charts/cp-kafka-connect/templates/deployment.yaml
  # lib/ros/be/application/services/templates/jobs/kafka-connect/connector-provision-job.yml.erb
  def deploy_commands(runtime)
    runtime.kubectl("create secret generic #{name} --from-literal=#{FIXED_FILE}=#{secret}")
  end

  def secret
    Cnfs.decrypt_file(full_path)
  end

  def full_path
    Cnfs.root.join(path)
  end
end
