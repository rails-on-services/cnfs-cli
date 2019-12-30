# frozen_string_literal: true

class Resource::Redis < Resource
  store :config, accessors: %i[clusters], coder: YAML
end
