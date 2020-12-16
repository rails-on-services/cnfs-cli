# frozen_string_literal: true

class Resource::Cli::Instance < Resource::Cli
  store :config, accessors: %i[version], coder: YAML
end
