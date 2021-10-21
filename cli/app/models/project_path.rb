# frozen_string_literal: true

class ProjectPath
  include ActiveModel::Model

  attr_accessor :paths, :context_attrs

  def path(from: nil, to: nil, absolute: false)
    if from.nil? && to.nil?
      # absolute ? project.root : Pathname.new('.')
      absolute ? Pathname.new('.').realpath : Pathname.new('.')
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
  # rubocop:disable Style/OptionalBooleanParameter
  def path_to(type, absolute_path = false)
    relative_path =
      case type.to_sym
      when :config
        paths.config # .join('environments', *owner.context_attrs)
      when :manifests
        paths.tmp.join('manifests', *context_attrs)
      when :repository
        owner.repository&.path
      when :repositories
        paths.src
      when :runtime
        paths.tmp.join('runtime', *context_attrs)
      when :services
        paths.data.join('services', *context_attrs)
      when :templates
        # paths.data.join('templates', *context_attrs)
        paths.data.join('templates', environment.name)
      else
        raise Cnfs::Error, "ProjectPath symbol not found for ':#{type}'"
      end
    # binding.pry
    # absolute_path ? project.root.join(relative_path) : relative_path
    absolute_path ? Pathname.new('.').realpath.join(relative_path) : relative_path
  end
  # rubocop:enable Style/OptionalBooleanParameter
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  # Used by all runtime templates; Returns a path relative from the 'from' path to the project root
  # or optionally from the 'from' path to the 'to' path in the project
  def relative_path(from, to = nil)
    if from.instance_of?(Symbol)
      return path_to(to).relative_path_from(path_to(from)) if to

      return project.root.relative_path_from(project.root.join(path_to(from)))
    end

    from = Pathname.new(from)
    return project.root.join(to ? path_to(to) : '').relative_path_from(from) if from.absolute?

    path_to(to).relative_path_from(from)
  end
  # rubocop:enable Metrics/AbcSize
end
