# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'solid_record'

SPEC_ROOT = Pathname.new(__dir__).join('..')

RSpec.configure do |config|
  config.before(:suite) { SolidRecord::DataStore.load } # Setup the A/R database connection
  SolidRecord.logger.level = :debug
end

class SpecHelper
  class << self
    def before_context(type)
      # Use load rather than require_relative as the models are required per context
      SPEC_ROOT.join('spec/dummy', type, 'app/models').glob('*.rb').each { |path| load path }
    end

    def after_context # rubocop:disable Metrics/AbcSize
      SolidRecord.tables.reject { |table| table.name.start_with?('SolidRecord') }.each do |klass|
        # remove the class from the tables array
        SolidRecord.tables.delete(klass)
        # remove any STI classes
        klass.descendants.each { |child| child.module_parent.send(:remove_const, child.name.demodulize.to_sym) }
        # remove the class
        klass.module_parent.send(:remove_const, klass.name.demodulize.to_sym)
      end
      ActiveSupport::Dependencies::Reference.clear! # Remove any A/R Cached Classes (e.g. STI classes)
    end
  end
end
