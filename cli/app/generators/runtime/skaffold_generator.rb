# frozen_string_literal: true

class Runtime::SkaffoldGenerator < RuntimeGenerator
  def files
    directory('files', path)
  end

  private

  # Override spacing
  def labels(labels: {}, space_count: 12)
    super
  end

  def internal_path
    Pathname.new(__dir__).join('..')
  end

  # TODO: needs to have namespace into api
  def application_hostname
    context.target.application.endpoint.cnfs_sub
  end

  # TODO: get the pull secret sorted
  # def pull_secret; Stack.registry_secret_name end
  def pull_secret
    'test'
  end

  def pull_policy
    'Always'
  end
end
