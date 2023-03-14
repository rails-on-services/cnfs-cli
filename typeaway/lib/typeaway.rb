# frozen_string_literal: true

require 'solid_support'
require 'solid_record' unless defined? APP_ROOT

module Typeaway
  def self.logger() = SolidSupport.logger
  class Error < StandardError; end
end

require 'typeaway/version'
require 'typeaway/application'
require 'typeaway/plugin'
require 'typeaway/extension'

load_path = Pathname.new(__dir__).join('../app')
SolidSupport.add_loader(name: :typeaway, path: load_path)
SolidSupport.load_all
