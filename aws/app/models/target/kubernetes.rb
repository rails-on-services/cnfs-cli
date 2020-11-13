# frozen_string_literal: true

class Target::Kubernetes < Target
  store :config, accessors: %i[role_name cluster_name], coder: YAML

  validates :role_name, presence: true
  validates :cluster_name, presence: true

  def role_name
    super.cnfs_sub
  end

  def init(options)
    provider.init_cluster(self, options)
  end
end
