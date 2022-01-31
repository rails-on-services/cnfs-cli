# frozen_string_literal: true

require 'pry'
require 'pry-byebug'

# Setting the environment to test causes
# - main_loader to skip MainCommand.start
# - SegmentRoot.load to be skipped
ENV['HENDRIX_CLI_ENV'] ||= 'test'

require 'bundler/setup'
require 'hendrix'

# Common, well known key which yields predictable results when decrypting values
# TODO: When encryption and keys move to SolidRecord this could go away as we don't need
# to test encryption of records
KEY_ID = '9346840c042bb4dbf7bd6a5cf49de40d420c3d1835b28044f9abcab3003c47a1'

# For OneStack specs SPEC_PATH will be nil
# If another gem requires this helper then it should have already defined SPEC_PATH
SPEC_PATH = Pathname.new(__dir__) unless defined? SPEC_PATH

Dir.chdir(SPEC_PATH.join('dummy')) { require 'hendrix/boot_loader' }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) { OneStack::SpecLoader.setup_project }
  config.after(:suite) { OneStack::SpecLoader.teardown_project }
end

module OneStack
  class SpecLoader
    class << self
      attr_accessor :current_spec

      def setup_project() = remove_temp_paths

      def teardown_project() = remove_temp_paths

      # Ensure the temporary paths are removed
      def remove_temp_paths
        [segments_path, cache_path, config_path, data_path].each do |path|
          path.rmtree if path.exist?
        end
        segments_yml_path.delete if segments_yml_path.exist?
      end

      def setup_segment(spec, load_nodes: false)
        SolidRecord::DataStore.reset
        @current_spec = spec
        stub_local_paths
        create_key unless keys_file.exist?
        stub_segments_path
        create_segments_yml
        copy_fixtures_to_segments

        # return unless load_nodes

        # OneStack.data_store.reset
        # TODO: If Node, Segment, etc move from core to OneStack then keep this, otherwise needs to be in spec itself
        # SegmentRoot.load
      end

      def stub_local_paths
        { cache_home: cache_path, config_home: config_path, data_home: data_path }.each do |method, path|
          current_spec.allow_any_instance_of(XDG::Environment).to(
            current_spec.receive(method).and_return(path)
          )
        end
      end

      # Create the key file in XDG.data_home with the preset key value
      def create_key
        data_path.mkpath
        File.write(keys_file, key_content.to_yaml)
      end

      def keys_file() = data_path.join('keys.yml')

      def key_content() = { OneStack.application.name => KEY_ID }

      def stub_segments_path
        OneStack.config.paths.segments = project_path.join('segments', *segments)
      end

      def segments() = current_spec.class.name.split('::')[2...].map { |str| str.gsub('Nested', '').downcase }

      def create_segments_yml() = FileUtils.cp(segments_source_path, segments_yml_path)

      # If a file exists by the same name as the current spec then use it as config/segments.yml
      def segments_source_path
        path = fixtures_path.join("segments/#{segments.join('/')}.yml")
        path.exist? ? path : project_path.join('config/segments.yml.bak')
      end

      def segments_yml_path() = project_path.join('config/segment.yml')

      def copy_fixtures_to_segments() = FileUtils.cp_r(fixtures_path.join('segments/.'), segments_path)

      def fixtures_path() = SPEC_PATH.join('fixtures')

      def segments_path() = project_path.join('segments')

      def project_path() = SPEC_PATH.join('dummy')

      def cache_path() = tmp_path.join('.cache')

      def config_path() = tmp_path.join('.config')

      def data_path() = tmp_path.join('.local/share')

      def tmp_path() = SPEC_PATH.join('tmp')

      def internal_path() = Pathname(__dir__)
    end
  end
end
