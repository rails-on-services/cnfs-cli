# frozen_string_literal: true

class Resource::Globalaccelerator < Resource
  store :config, accessors: %i[hostname], coder: YAML
end
