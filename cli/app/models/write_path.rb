# frozen_string_literal: true

class WritePath
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :project

  # Example: write_path(:manifests) # => #<Pathname:tmp/cache/development/main>
  def write_path(type = :manifests, absolute_path = false)
    relative_path = case type.to_sym
    when :config
      project.paths.config.join('environments', *project.context_attrs)
    when :manifests
      project.paths.tmp.join('manifests', *project.context_attrs)
    when :repository
      project.repository&.path
    when :repositories
      project.paths.src
    when :runtime
      project.paths.tmp.join('runtime', *project.context_attrs)
    when :services
      project.paths.data.join('services', *project.context_attrs)
    when :templates
      # paths.data.join('templates', *context_attrs)
      project.paths.data.join('templates', project.environment.name)
    end
    absolute_path ? Cnfs.project.root.join(relative_path) : relative_path
  end

  # Used by all runtime templates; Returns a path relative from the write path to the project root
  # Example: relative_path(:deployment) # => #<Pathname:../../../..>
  def relative_path(path_type = :manifests)
    Cnfs.project_root.relative_path_from(Cnfs.project_root.join(write_path(path_type)))
  end

  def x_relative_path(path)
    Cnfs.project_root.relative_path_from(Cnfs.project_root.join(path))
  end
end
