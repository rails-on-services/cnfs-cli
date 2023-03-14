# frozen_string_literal: true

require 'bundler/setup'
SPEC_PATH = Pathname.new(__dir__)
require 'one_stack/spec_helper'

# Common, well known key which yields predictable results when decrypting values
# TODO: When encryption and keys move to SolidRecord this could go away as we don't need
# to test encryption of records
# KEY_ID = '9346840c042bb4dbf7bd6a5cf49de40d420c3d1835b28044f9abcab3003c47a1'

# For OneStack specs SPEC_PATH will be nil
# If another gem requires this helper then it should have already defined SPEC_PATH

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # config.before(:suite) { OneStack::SpecHelper.setup_project }
  # config.after(:suite) { OneStack::SpecHelper.teardown_project }
end
