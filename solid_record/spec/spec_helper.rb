# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'solid_record'

SPEC_ROOT = Pathname.new(__dir__).join('..')

RSpec.configure do |config|
  config.before(:suite) { SolidRecord::DataStore.load } # Setup the A/R database connection
end

class SpecHelper
  class << self
    def before_context(type)
      Pathname.new('.').glob(SPEC_ROOT.join("spec/dummy/#{type}/app/models/*.rb")).each { |path| require_relative path }
    end

    def after_context # rubocop:disable Metrics/AbcSize
      SolidRecord.tables.reject { |table| table.name.start_with?('SolidRecord') }.each do |klass|
        SolidRecord.tables.delete(klass)
        klass.descendants.each { |child| child.module_parent.send(:remove_const, child.name.demodulize.to_sym) }
        klass.module_parent.send(:remove_const, klass.name.demodulize.to_sym)
      end
    end
  end
end
