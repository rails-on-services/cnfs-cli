# frozen_string_literal: true

module SolidSupport
  class Project::ApplicationGenerator < ProjectGenerator
    # def data_files
    #   data_path.rmtree if data_path.exist?
    #   create_file(data_path.join('keys.yml'), { name => Lockbox.generate_key }.to_yaml)
    # end

    def project_files() = directory('files', '.')

    def app_structure() = super

    private

    def gemfile_gem_string(name)
      gem_name = name.empty? ? gem_name_root : "#{gem_name_root}-#{name}"
      return "gem '#{gem_name}'" if ENV['CNFS_ENV'].eql?('production')

      name = gem_name_root if name.empty?
      "gem '#{gem_name}', path: '#{gems_path.join(name)}'"
    end

    def gems_path() = internal_path.join('../../../../../')

    def internal_path() = Pathname.new(__dir__)

    def gems = ['']
    # def data_path() = CnfsCli.config.data_home.join('projects', uuid)
  end
end
