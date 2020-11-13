# frozen_string_literal: true

class NamespaceGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_key
    # template(views_path.join('keys.yml.erb'), Cnfs.user_root.join(options.project_name, 'config/environments', options.environment, name, 'keys.yml'))
    template(views_path.join('templates/keys.yml.erb'), Cnfs.user_root.join(options.project_name, 'config/environments', options.environment, name, 'keys.yml'))
  end

  def generate_project_files
    # inside("#{Cnfs.config.paths.config}/#{options.environment}") do
    inside(Cnfs.paths.config.join('environments', options.environment)) do
      empty_directory(name)
      # template(views_path.join('templates/keys.yml.erb'), Cnfs.user_root.join(options.environment, name, 'config/keys.yml'))
      template(views_path.join('templates/services.yml.erb'), "#{name}/services.yml")
      inject_into_file('namespaces.yml') do
        "\n#{name}:
config:
  #{name}: yes"
      end
    end
  end

  private

  def source_paths
    [views_path, views_path.join('templates')]
  end

  def views_path
    @views_path ||= internal_path.join('../views/component')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
