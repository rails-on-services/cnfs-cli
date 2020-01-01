# frozen_string_literal: true

class NewGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_project_files
    directory('files', '.')
    template('cnfs', '.cnfs')
  end

  def generate_encryption_key
    Cnfs.setup_paths(destination_root)
    template('credentials', Cnfs.box_file)
  end

  private

  def source_paths; [views_path, views_path.join('templates')] end

  def views_path
    @views_path ||= internal_path.join('../views')
      .join(self.class.name.demodulize.delete_suffix('Generator').underscore)
  end

  def internal_path; Pathname.new(__dir__) end
end
