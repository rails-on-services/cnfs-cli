# frozen_string_literal: true

class ProjectGenerator < NewGenerator
  def user_files
    user_project_path.rmtree if user_project_path.exist?
    create_file(user_project_path.join("#{name}.yml"), { 'name' => name, 'key' => Lockbox.generate_key }.to_yaml)
    create_file('.cnfs', '')
    directory('files', '.')
  end

  def templates
    template_files.sort.each do |template|
      destination = template.relative_path_from(templates_path).to_s.delete_suffix('.erb')
      template(template, destination)
      gsub_file(destination, /^#./, '') if options.config && destination.end_with?('.yml')
    end
  end

  private

  def user_project_path() = user_path.join(uuid)

  def uuid() = @uuid ||= SecureRandom.uuid

  def template_files() = templates_path.glob('**/*.erb')

  def templates_path() = views_path.join('templates')
end
