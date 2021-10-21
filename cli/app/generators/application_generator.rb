# frozen_string_literal: true

class ApplicationGenerator < Thor::Group
  include Thor::Actions
  argument :runtime
  argument :context

  private

  # def destination_root
  #   context.manifest.write_path.to_s
  # end

  def source_paths
    @source_paths ||= plugin_paths.each_with_object([]) { |path, a| a.append(path, path.join('templates')) }
  end

  def plugin_paths
    CnfsCli.plugins.values.append(CnfsCli).map do |plugin|
      plugin.gem_root.join('app/generators', caller_path, generator_type)
    end.select { |path| path.exist? }
  end

  # returns 'compose', 'skaffold', 'terraform', etc
  def generator_type
    self.class.name.demodulize.delete_suffix('Generator').underscore
  end

  def remove_stale_files
    (all_files - excluded_files - generated_files).each do |file|
      remove_file(file)
    end
  end

  def all_files
    Dir[path.join('**/*')].reject { |fn| File.directory?(fn) }
  end

  def excluded_files
    []
  end

  def generated_files
    @generated_files ||= []
  end
end
