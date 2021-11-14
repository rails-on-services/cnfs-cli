# frozen_string_literal: true

class ProjectGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_project_files
    user_project_dir = CnfsCli.config.config_home
    user_project_dir.rmtree if user_project_dir.exist?
    # TODO: The save of this should be done with Node class
    config = YAML.load_file(CnfsCli.gem_root.join('project.yml'))
    config.merge!(name: name).stringify_keys!
    create_file('project.yml', config.to_yaml)
    directory('files', '.')
    # template('README.md')
    template_files.sort.each do |template|
      destination = template.delete_suffix('.erb')
      template("templates/#{template}", destination)
      gsub_file(destination, /^#./, '') # if options.config
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
