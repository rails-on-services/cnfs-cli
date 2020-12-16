# frozen_string_literal: true

class NamespaceGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_user_files
    user_file_path = Cnfs.user_root.join(Cnfs.config.name, Cnfs.paths.config, ns_file)
    empty_directory(user_file_path.split.first)
    template('user_namespace.yml.erb', user_file_path) if behavior.eql?(:invoke)
  end

  def generate_project_files
    project_file_path = Cnfs.paths.config.join(ns_file)
    empty_directory(project_file_path.split.first)
    template('namespace.yml.erb', project_file_path) if behavior.eql?(:invoke)
  end

  private

  def ns_file
    ['environments', options.environment, name, 'namespace.yml'].join('/')
  end

  def source_paths
    [views_path, views_path.join('templates')]
  end

  def views_path
    @views_path ||= internal_path.join('namespace')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
