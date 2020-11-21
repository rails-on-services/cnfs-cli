# frozen_string_literal: true

class NamespaceGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_key
    # binding.pry
    # template(views_path.join('keys.yml.erb'), Cnfs.user_root.join(options.project_name, 'config/environments', options.environment, name, 'keys.yml'))
    # template(internal_path.join('templates/keys.yml.erb'), Cnfs.user_root.join(Cnfs.config.name, 'config/environments', options.environment, name, 'keys.yml'))
    template(internal_path.join('key/keys.yml.erb'), Cnfs.user_root.join(Cnfs.config.name, 'config/environments', options.environment, name, 'keys.yml'))
  end

  def generate_project_files
    inside(Cnfs.paths.config.join('environments', options.environment)) do
      # Directory is required for Namespace parser to pick up valid namespaces
      empty_directory(name)
      template(views_path.join('namespace.yml.erb'), "#{name}.yml")
      # template(views_path.join('templates/keys.yml.erb'), Cnfs.user_root.join(options.environment, name, 'config/keys.yml'))
      #template(views_path.join('templates/services.yml.erb'), "#{name}/services.yml")
    end
  end

  private

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
