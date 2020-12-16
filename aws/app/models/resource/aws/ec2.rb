# frozen_string_literal: true

class Resource::Aws::EC2 < Resource::Aws
  store :config, accessors: %i[eip instance_type key_name], coder: YAML
end
