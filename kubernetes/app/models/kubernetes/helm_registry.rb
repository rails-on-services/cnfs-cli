# frozen_string_literal: true

class Kubernetes::HelmRegistry < Registry
  store :config, accessors: %i[url], coder: YAML

  def add_deploy_commands(runtime)
    runtime.response.add(exec: "helm repo add #{name} #{url}", pty: true)
    runtime.response.add(exec: 'helm repo update', pty: true)
  end
end
