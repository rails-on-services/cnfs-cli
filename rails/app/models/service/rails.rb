# frozen_string_literal: true

class Service::Rails < Service
  # attr_accessor :images
  # NOTE: project_path, e.g. 'whistler' is relative to build_context_path which is 'project_root/src'
  # NOTE: dockerfile is also relative to build_context_path
  store :config, accessors: %i[project_path], coder: YAML
  # store :config, accessors: %i[project_path dockerfile image_gems build_args], coder: YAML
  # store :config, accessors: %i[image_repository image_tag], coder: YAML
  store :image, accessors: %i[gems], coder: YAML
  # store :config, accessors: %i[console_command database_seed_commands test_commands], coder: YAML

  # store :config, accessors: %i[volumes], coder: YAML

  after_initialize do
    self.volumes ||= []
    self.project_path ||= '.'
  end

  def build_context_path
    project.path(from: :manifests, to: :repositories)
  end
end
