# frozen_string_literal: true

class Resource::Aws::Redshift::Cluster < Resource::Aws::Redshift
  store :config, accessors: %i[node_type], coder: YAML
end
