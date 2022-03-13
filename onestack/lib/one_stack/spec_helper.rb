# frozen_string_literal: true

require 'pry'
# require 'pry-byebug'

# Setting the environment to test causes
# - main_loader to skip MainCommand.start
# - SegmentRoot.load to be skipped
ENV['HENDRIX_CLI_ENV'] ||= 'test'
Dir.chdir(SPEC_PATH.join('dummy')) { require 'hendrix/boot_loader' }

RSpec.configure do |config|
  config.after(:suite) { OneStack::SpecHelper.teardown_project }
end

module OneStack
  class SpecHelper
    class << self
      # Ensure the temporary paths are removed
      def teardown_project() = tmp_path.rmtree

      def setup_segment(spec)
        stub_local_paths(spec)
        create_keys_file unless keys_file.exist?
      end

      def stub_local_paths(current_spec)
        { cache_home: '.cache', config_home: '.config', data_home: data_path }.each do |method, path|
          current_spec.allow_any_instance_of(XDG::Environment).to(
                                                    current_spec.receive(method).and_return(tmp_path.join(path))
          )
        end
      end

      # Create the key file in XDG.data_home with the preset key value
      def create_keys_file
        keys_file.parent.mkpath
        File.write(keys_file, key_content.to_yaml)
      end

      def keys_file() = @keys_file ||= tmp_path.join(data_path, OneStack.config.xdg_name, 'keys.yml')

      def key_content() = { OneStack.application.name => Lockbox.generate_key } #KEY_ID }

      def data_path() = '.local/share'

      def tmp_path() = @tmp_path ||= Pathname.new(Dir.mktmpdir)
    end
  end
end
