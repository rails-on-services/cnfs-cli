# frozen_string_literal: true

class EnvironmentGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_user_files
    user_file_path = Cnfs.user_root.join(Cnfs.config.name, Cnfs.paths.config, env_path, 'environment.yml')
    template('user_environment.yml.erb', user_file_path)
  end

  def generate_project_files
    project_file_path = Cnfs.paths.config.join(env_path)
    return empty_directory(project_file_path) if behavior.eql?(:revoke)

    %w[environment.yml resources.yml].each do |file|
      template("#{file}.erb", project_file_path.join(file))
      gsub_file(project_file_path.join(file), /^#./, '') if options.config
    end
  end

  private

  def env_path
    ['environments', name].join('/')
  end

  def source_paths
    [views_path, views_path.join('templates')]
  end

  def views_path
    @views_path ||= internal_path.join('environment')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
