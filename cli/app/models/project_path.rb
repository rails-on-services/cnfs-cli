# frozen_string_literal: true

class ProjectPath
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def path(from: nil, to: nil, absolute: false)
    if from.nil? && to.nil?
      absolute ? project.root : Pathname.new('.')
    elsif from.nil?
      path_to(to, absolute)
    else
      relative_path(from, to)
    end
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def path_to(type, absolute_path = false)
    relative_path =
      case type.to_sym
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
    absolute_path ? project.root.join(relative_path) : relative_path
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  # Used by all runtime templates; Returns a path relative from the 'from' path to the project root
  # or optionally from the 'from' path to the 'to' path in the project
  def relative_path(from, to = nil)
    if from.class.eql?(Symbol)
      return path_to(to).relative_path_from(path_to(from)) if to

      return project.root.relative_path_from(project.root.join(path_to(from)))
    end

    from = Pathname.new(from)
    return project.root.join(to ? path_to(to) : '').relative_path_from(from) if from.absolute?

    path_to(to).relative_path_from(from)
  end
  # rubocop:enable Metrics/AbcSize
end
