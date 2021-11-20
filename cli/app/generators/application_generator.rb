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
    @source_paths ||= repo_paths # .each_with_object([]) { |path, a| a.append(path, path.join('templates')) }
  end

  # TODO: All content comes from Repository and Project Components so source paths reflect that
  # This should not use loaders to get the path, but rather the component which can be referenced from context
  def repo_paths
    Cnfs.loaders.except('core').keys.each_with_object([]) do |repo, ary|
      repo_name, comp_name = repo.split('/')
      ary.append(CnfsCli.configuration.paths.src.join(repo_name, 'components', comp_name, 'app/generators', generator_type))
      Cnfs.logger.warn(ary)
    end.select(&:exist?)
  end

  # def plugin_paths
  #   CnfsCli.plugins.values.append(CnfsCli).map do |plugin|
  #     plugin.gem_root.join('app/generators', caller_path, generator_type)
  #   end.select(&:exist?)
  # end

  # returns 'compose', 'skaffold', 'terraform', etc
  def generator_type
    # self.class.name.demodulize.delete_suffix('Generator').underscore
    self.class.name.deconstantize.underscore
  end

  def remove_stale_files
    (all_files - excluded_files - generated_files).each do |file|
      remove_file(file)
    end
  end

  def all_files
    Dir[path.join('**/*')].reject { |fn| File.directory?(fn) }
  end

  # Array of file names that should not be removed
  def excluded_files
    []
  end

  # Builds an array of files that are created during an invocation of the Generator
  def generated_files
    @generated_files ||= []
  end
end
