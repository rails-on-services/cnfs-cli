# frozen_string_literal: true

# require 'bundler/setup'
require 'pry'
require 'pry-byebug'
require 'active_support/concern'
require 'active_support/core_ext/hash'

require 'cnfs_cli/terraform'

require 'nulldb_rspec'
ActiveRecord::Base.establish_connection(adapter: :nulldb, schema: 'schema.rb')
NullDB.configure { |config| config.project_root = 'spec/fixtures' }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
