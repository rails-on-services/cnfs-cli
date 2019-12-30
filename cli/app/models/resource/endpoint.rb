# frozen_string_literal: true

class Resource::Endpoint < Resource
  store :config, accessors: %i[hostname scheme], coder: YAML
end
