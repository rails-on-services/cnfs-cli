# frozen_string_literal: true

class ApplicationGenerator < Thor::Group
  include Thor::Actions
  argument :project

  private

  def source_paths
    @source_paths ||= plugin_paths.each_with_object([]) { |path, a| a.append(path, path.join('templates')) }
  end

  def plugin_paths
    Cnfs.plugins.values.map do |plugin|
      plugin.plugin_lib.gem_root.join('app/generators/runtime', generator_type)
    end.select { |path| path.exist? }.append Cnfs.gem_root.join('app/generators/runtime', generator_type)
  end

  def generator_type
    self.class.name.demodulize.delete_suffix('Generator').underscore
  end

  def entity_to_template(entity = nil)
    entity ||= instance_variable_get("@#{entity_name}")
    key = entity.template || entity.type&.demodulize&.underscore || entity.name
    entity_template_map[key.to_sym] || key
  end

  def entity_template_map
    {}
  end

  def generate_entity_manifests
    entities.each do |entity|
      instance_variable_set("@#{entity_name}", entity)
      # entity.send(:project=, project)
      generated_files << generate
    end
  rescue StandardError => e
    # TODO: add to errors array and have controller output the result
    error_on = instance_variable_get("@#{entity_name}")
    raise Cnfs::Error, "\nError generating template for #{entity_name} '#{error_on.name}': #{e}\n#{error_on.to_json}"
  end

  def remove_stale_files
    (all_files - excluded_files - generated_files).each do |file|
      remove_file(file)
    end
  end

  def all_files
    Dir[write_path(path_type).join('**/*')]
  end

  def path_type
    nil
  end

  def excluded_files
    []
  end

  def generated_files
    @generated_files ||= []
  end

  # Used by all runtime templates; Returns a path relative from the write path to the project root
  # Example: relative_path(:deployment) # => #<Pathname:../../../..>
  def relative_path(path_type = :deployment)
    project.relative_path(path_type)
  end

  def write_path(type = :deployment)
    project.write_path(type)
  end
end
