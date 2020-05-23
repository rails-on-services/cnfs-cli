# frozen_string_literal: true

class Resource::Kubernetes < Resource
  store :config, accessors: %i[name tags], coder: YAML
  store :config, accessors: %i[aws_profile admins worker_groups worker_groups_launch_template services], coder: YAML

  def name
    super || 'default'
  end

  def tags
    super || []
  end

  def admins
    super || []
  end
end
