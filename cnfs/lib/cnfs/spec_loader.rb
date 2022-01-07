# frozen_string_literal: true

require 'pry'
require 'pry-byebug'

# Setting the environment to test causes
# - app_loader to skip MainController.start
# - SegmentRoot.load to be skipped
ENV['CNFS_CLI_ENV'] ||= 'test'

ROOT_FILE_ID = 'config/environment.rb'

PROJECT_NAME = 'spec'
PROJECT_ID = '3273b2fc-ff9c-4d64-8835-34ee3328ad68'
KEY_ID = '9346840c042bb4dbf7bd6a5cf49de40d420c3d1835b28044f9abcab3003c47a1'

# Must match the value in Cnfs::Application::Configuration::XDG_PROJECTS_BASE 
XDG_PROJECTS_BASE = 'cnfs-cli/projects'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) { Cnfs::SpecLoader.setup_project }
  # config.after(:suite) { Cnfs::SpecLoader.remove_project }
end

module Cnfs
  class SpecLoader
    class << self
      attr_accessor :current_spec

      def setup_project
        # Ensure the temporary project path is removed
        remove_project
        project_path.mkpath

        # Copy the gems fixtures to the temporary project path
        FileUtils.cp_r(fixtures_path, project_path)

        # Copy the common fixtures (application configuration) to the temporary project path
        common_path = internal_path.join('../../spec/fixtures/.')
        FileUtils.cp_r(common_path, project_path)

        # Create the key file in XDG.data_home with the preset key value
        keys_path = data_path.join("#{XDG_PROJECTS_BASE}/#{PROJECT_ID}")
        keys_path.mkpath
        key_content = { PROJECT_NAME => KEY_ID }
        File.open(keys_path.join('keys.yml'), 'w') { |f| f.write(key_content.to_yaml) }

        # CD to the project_path and load the app
        Dir.chdir(project_path) do
          require 'bundler/setup'
          require 'cnfs/boot_loader'
        end
      end

      def setup_segment(spec, load_nodes: false)
        @current_spec = spec
        stub_local_paths
        stub_segments_path
        FileUtils.cp(segments_yml_path, project_path.join('config/segments.yml'))
        return unless load_nodes

        Cnfs.data_store.reset
        # TODO: If Node, Segment, etc move from core to cnfs then keep this, otherwise needs to be in spec itself
        SegmentRoot.load
      end

      # If a file exists by the same name as the current spec then use it as config/segments.yml
      def segments_yml_path
        path = fixtures_path.join("segments/#{segments.join('/')}.yml")
        path.exist? ? path : project_path.join('config/segments.yml.bak') 
      end

      def stub_local_paths
        { cache_home: cache_path, config_home: config_path, data_home: data_path }.each do |method, path|
          current_spec.allow_any_instance_of(XDG::Environment).to(
            current_spec.receive(method).and_return(path))
        end
      end

      def stub_segments_path
        Cnfs.config.paths.segments = project_path.join('segments', *segments)
      end

      def segments() = current_spec.class.name.split('::')[2...].map { |str| str.gsub('Nested', '').downcase }

      def remove_project
        [project_path, cache_path, config_path, data_path].each do |path|
          path.rmtree if path.exist?
        end
      end

      def project_path() = tmp_path.join('project')

      def cache_path() = tmp_path.join('.cache')

      def config_path() = tmp_path.join('.config')

      def data_path() = tmp_path.join('.local/share')

      def fixtures_path() = SPEC_DIR.join('fixtures/.')

      def tmp_path() = SPEC_DIR.join('tmp')

      def internal_path() = Pathname(__dir__)
    end
  end
end
