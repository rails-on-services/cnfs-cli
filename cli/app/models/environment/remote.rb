# frozen_string_literal: true

class Environment::Remote < Environment
  store :config, accessors: %i[domain_2 other], coder: YAML

  # store :config, accessors: %i[instance_id], coder: YAML

  # belongs_to :instance, class_name: 'Resource'
end
