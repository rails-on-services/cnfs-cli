# frozen_string_literal: true

module Hendrix
  class New::ProjectGenerator < NewGenerator
    # def data_files
    #   data_path.rmtree if data_path.exist?
    #   create_file(data_path.join('keys.yml'), { name => Lockbox.generate_key }.to_yaml)
    # end

    def project_files() = directory('files', '.')

    def template_files
      templates.each do |template|
        destination = template.relative_path_from(templates_path).to_s.delete_suffix('.erb')
        template(template, destination)
      end
    end

    def component_files() = _component_files

    private

    def internal_path() = Pathname.new(__dir__)

    # def data_path() = CnfsCli.config.data_home.join('projects', uuid)

    def uuid() = @uuid ||= SecureRandom.uuid
  end
end
