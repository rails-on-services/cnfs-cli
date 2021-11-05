# frozen_string_literal: true

class Aws::Resource::Route53 < Aws::Resource
  store :config, accessors: %i[zone hosts], coder: YAML
  store :zone, accessors: %i[root], coder: YAML
end
