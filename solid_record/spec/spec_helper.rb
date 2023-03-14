# frozen_string_literal: true

require 'pry'
require 'bundler/setup'
require 'solid_record'
# require 'solid_support'

SPEC_ROOT = Pathname.new(__dir__).join('..')
DUMMY_ROOT = SPEC_ROOT.join('spec/dummy')

module Helpers
  def xdoc(klass, hash) = SolidRecord.toggle_callbacks { klass.create(hash) }
end

RSpec.configure do |config|
  # config.before(:suite) { SolidRecord::DataStore.load } # Setup the A/R database connection
  SolidRecord.logger.level = :warn # debug
  SolidRecord.config.sandbox = true
  config.before(:suite) do
    DUMMY_ROOT.children.select(&:directory?).each do |path|
      require path.join('models') if path.join('models.rb').exist?
    end
  end
  config.include Helpers
end

class SpecHelper
  class << self
    # def before_context(type)
      # Use load rather than require_relative as the models are required per context
      # NOTE: If the context needs to load multiple models then it handles that itself
      # load DUMMY_ROOT.join(type.to_s, 'models.rb') # .glob('*.rb').each { |path| load path }
    # end

    # def after_context # rubocop:disable Metrics/AbcSize
    #   SolidRecord.tables.reject { |table| table.name.start_with?('SolidRecord') }.each do |klass|
    #     # remove the class from the tables array
    #     SolidRecord.tables.delete(klass)
    #     # remove any STI classes
    #     klass.descendants.each { |child| child.module_parent.send(:remove_const, child.name.demodulize.to_sym) }
    #     # remove the class
    #     klass.module_parent.send(:remove_const, klass.name.demodulize.to_sym)
    #   end
    #   ActiveSupport::Dependencies::Reference.clear! # Remove any A/R Cached Classes (e.g. STI classes)
    # end
  end
end
