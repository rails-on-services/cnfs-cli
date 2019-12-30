# frozen_string_literal: true

class Resource::Bucket < Resource
  store :config, accessors: %i[services], coder: YAML
  # store :resources0, accessors: %i[services], coder: YAML
  def buckets; YAML.load(resources) end
end
