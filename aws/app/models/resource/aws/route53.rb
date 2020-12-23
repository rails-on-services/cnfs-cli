# frozen_string_literal: true

class Resource::Aws::Route53 < Resource::Aws
  store :config, accessors: %i[zone hosts], coder: YAML
  store :zone, accessors: %i[root], coder: YAML
end
