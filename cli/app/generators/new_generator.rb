# frozen_string_literal: true

class NewGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_project_files
    copy_file(Cnfs.gem_root.join('config/cnfs.yml'), 'cnfs.yml')
    directory('files', '.')
    template('../component/templates/services.yml.erb', 'config/environments/services.yml')
    fixture_names.sort.each do |fixture_file|
      template("templates/#{fixture_file}", fixture_file.delete_suffix('.erb'))
    end
  end

  private

  def fixture_names
    Dir.chdir(views_path.join('templates')) { Dir['**/*.erb'] }
  end

  def source_paths
    [views_path]
  end

  def views_path
    @views_path ||= internal_path.join('../views/new')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
