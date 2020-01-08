# frozen_string_literal: true

class Target::Kubernetes < Target

  # This is for k8s cluster settings
  # TODO: move targets to a type; remove 
  store :config, accessors: %i[role_name cluster_name], coder: YAML

  def init(options)
    provider.init_cluster(self, options)
  end
end
