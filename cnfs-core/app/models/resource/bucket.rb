# frozen_string_literal: true

class Resource::Bucket < Resource
  store :config, accessors: %i[services], coder: YAML
end
