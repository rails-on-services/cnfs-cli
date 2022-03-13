# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'solid_view'

SPEC_ROOT = Pathname.new(__dir__).join('..')

RSpec.configure do |config|
  # config.before(:suite) { SolidRecord::DataStore.load } # Setup the A/R database connection
  # SolidRecord.logger.level = :warn # debug
  # SolidRecord.config.sandbox = true
end
