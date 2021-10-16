# frozen_string_literal: true

require 'bundler/setup'
require 'pry'

lib_path = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
ENV['RSPEC'] = '1'
ENV['CNFS_LOGGING'] = 'info'
ENV['CNFS_ENV'] = 'test'
# ENV['CNFS_LOGGING'] = 'debug'
ENV['SPEC_DIR'] = __dir__

require 'cnfs_cli'
require 'cnfs'

# @path = Pathname.new(__dir__).join('fixtures/project_1')
# Dir.chdir(@path) do
  # CnfsCli.run!
  # require 'cnfs/configuration'
  # Cnfs::Configuration.initialize!
# end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
