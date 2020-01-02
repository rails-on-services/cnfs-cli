# frozen_string_literal: true

class NewGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_project_files
    directory('files', '.')
    template('cnfs', '.cnfs')
  end

  def setup_project
    Cnfs.setup_paths(destination_root)
    empty_directory(Cnfs.user_config_path)
  end

  def generate_encryption_key
    template('credentials', Cnfs.box_file)
  end

  private

  def source_paths; [views_path, views_path.join('templates')] end

  def views_path; @views_path ||= internal_path.join('../views/new') end

  def internal_path; Pathname.new(__dir__) end
end
