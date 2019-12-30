# frozen_string_literal: true

class Resource::Instance < Resource
  store :config, accessors: %i[name_prefix ec2_key_pair], coder: YAML
end
