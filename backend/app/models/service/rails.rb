# frozen_string_literal: true

class Service::Rails < Service
  # attr_accessor :images
  # NOTE: project_path, e.g. 'whistler' is relative to build_context_path which is 'project_root/src'
  # NOTE: dockerfile is also relative to build_context_path
  store :config, accessors: %i[project_path dockerfile profiles image_gems build_args], coder: YAML
  store :config, accessors: %i[image_repository image_tag], coder: YAML
  store :config, accessors: %i[console_command database_seed_commands test_commands], coder: YAML

  store :config, accessors: %i[volumes], coder: YAML

  after_initialize do
    self.profiles ||= {}
    self.volumes ||= []
    self.project_path ||= '.'
    self.dockerfile ||= 'Dockerfile'
  end


  def git
    Dir.chdir(Cnfs.paths.src.join(self.build_args['source_path'])) do
    # Dir.chdir(application.apps_path.join(project_path)) do
      return Config::Options.new.merge!(sha: '', branch_name: '') unless system('git rev-parse --git-dir > /dev/null 2>&1')

      Config::Options.new(
        tag_name: `git tag --points-at HEAD`.chomp,
        branch_name: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
        sha: `git rev-parse --short HEAD`.chomp
      )
    end
  end

  def build_context_path
    Cnfs.paths.src.join(self.build_args['source_path'])
    # binding.pry
    # application.relative_path.join(application.apps_path_name)
  end
end
