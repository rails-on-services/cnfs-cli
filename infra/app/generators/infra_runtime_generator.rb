# frozen_string_literal: true

class InfraRuntimeGenerator < ApplicationGenerator
  attr_accessor :resource

  def invoke_parent_methods
    generate_entity_manifests
    remove_stale_files
  end

  private

  def entity_name
    :blueprint
  end

  def entities
    [context.target.blueprint]
  end

  def internal_path
    Pathname.new(__dir__)
  end

  def source_paths
    super.map { |path| path.join(context.target.provider.type.demodulize.underscore) }
  end

  def path_type
    :infra
  end
end
