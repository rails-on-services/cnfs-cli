# frozen_string_literal: true

class ProjectGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_project_files
    config = YAML.load_file(Cnfs.gem_root.join(Cnfs::PROJECT_FILE))
    config.merge!(name: name).transform_keys! { |k| k.to_s }
    create_file(Cnfs::PROJECT_FILE, config.to_yaml)
    directory('files', '.')
    # template('README.md')
    template_files.sort.each do |template|
      template("templates/#{template}", template.delete_suffix('.erb'))
    end
  end

  private

  def template_files
    Dir.chdir(views_path.join('templates')) { Dir['**/*.erb'] }
  end

  def source_paths
    [views_path]
  end

  def views_path
    @views_path ||= internal_path.join('project')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
