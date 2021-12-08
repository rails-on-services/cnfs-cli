# frozen_string_literal: true

class New::ProjectGenerator < NewGenerator
  def user_files
    data_path.rmtree if data_path.exist?
    create_file(data_path.join('keys.yml'), { name => Lockbox.generate_key }.to_yaml)
    create_file('.cnfs', '### No Content - DO NOT REMOVE')
    directory('files', '.')
  end

  def template_files
    templates.sort.each do |template|
      destination = template.relative_path_from(templates_path).to_s.delete_suffix('.erb')
      template(template, destination)
      gsub_file(destination, /^#./, '') if options.config && destination.end_with?('.yml')
    end
  end

  private

  def internal_path() = Pathname.new(__dir__)

  def data_path() = CnfsCli.config.data_home.join('projects', uuid)

  def uuid() = @uuid ||= SecureRandom.uuid
end
