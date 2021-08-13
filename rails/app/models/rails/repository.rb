# frozen_string_literal: true

class Rails::Repository < Repository
  store :config, accessors: %i[namespace service_type test_framework ruby_version], coder: YAML
  store :dockerfile, accessors: %i[static_gems image image_base bundle_home gem_home repo_name repo_path upstream_repo_name upstream_repo_path], coder: YAML
  store :build, accessors: %i[with_source with_upstream_source]

  # serialize :static_gems, Array
  def after_init
    binding.pry
    # TODO: clone the repo
    # TODO: copy in the services.yml file to the project
  end
end
