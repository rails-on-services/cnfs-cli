# frozen_string_literal: true

class ApplicationGenerator < Thor::Group
  include Thor::Actions

  # Argument order: context is received first. Any additional arugments are declared in sub-classes
  argument :context

  private

  # All content comes from Repository and Project Components so source paths reflect that
  # TODO: This probably needs to be further filtered based on the blueprint in the case of Provisoners
  # and by Resource? in the case of Runtimes
  # In fact this may need to be refactored from a global CnfsCli registry to a component hierarchy based
  def source_paths
    @source_paths ||= CnfsCli.loaders.values.map { |path| path.join('generators', generator_type) }.select(&:exist?)
  end

  # returns 'compose', 'skaffold', 'terraform', etc
  def generator_type() = self.class.name.deconstantize.underscore

  # After the generator has completed ti may call this method to remove old files
  def remove_stale_files() = (all_files - excluded_files - generated_files).each { |file| remove_file(file) }

  # All files in the destination directory
  def all_files() = path.glob('**/*').select(&:file?)

  # Array of file names that should not be removed
  # A subclass should override this method to define files that should not be considered as stale and removed
  def excluded_files() = []

  # Stores an array of files that are created during an invocation of the Generator
  def generated_files() = @generated_files ||= []
end
