# frozen_string_literal: true

class Resource::Postgres < Resource
  store :config, accessors: %i[clusters], coder: YAML
end
