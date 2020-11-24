# frozen_string_literal: true

class ProjectPath
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  # Example: absolute_path_to(:manifests) # => #<Pathname:/home/user/project/tmp/cache/development/main>
  def absolute_path_to(type)
    path_to(type, true)
  end

  # Example: path_to(:manifests) # => #<Pathname:tmp/cache/development/main>
  def path_to(type, absolute_path = false)
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

  # Used by all runtime templates; Returns a path relative from the 'from' path to the project root
  # or optionally from the 'from' path to the 'to' path in the project
  # Example: relative_path(from: :manifests) # => #<Pathname:../../../..>
  # Example: relative_path(from: :manifests, to: :repository) # => #<Pathname:../../../../src/ros>
  def relative_path(from:, to: nil)
    return path_to(to).relative_path_from(path_to(from)) if to

    project.root.relative_path_from(project.root.join(path_to(from)))
  end
end
