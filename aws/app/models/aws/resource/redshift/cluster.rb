# frozen_string_literal: true

class Aws::Resource::Redshift::Cluster < Aws::Resource::Redshift
  store :config, accessors: %i[node_type], coder: YAML
end
