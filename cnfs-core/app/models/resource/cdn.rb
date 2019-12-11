# frozen_string_literal: true

class Resource::Cdn < Resource
  store :config, accessors: %i[bucket hostname], coder: YAML
end
