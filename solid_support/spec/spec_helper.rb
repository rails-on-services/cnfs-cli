# frozen_string_literal: true

require 'bundler/setup'
require 'pry-byebug'

binding.pry

SPEC_ROOT = Pathname.new(__dir__).join('..')

RSpec.configure do |config|
  # SolidRecord.logger.level = :warn # debug
  # SolidRecord.config.sandbox = true
end
