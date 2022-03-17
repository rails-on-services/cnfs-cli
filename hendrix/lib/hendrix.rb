# frozen_string_literal: true

require 'solid_record' unless defined? APP_ROOT

require 'hendrix/version'
require 'hendrix/application'
require 'hendrix/plugin'
require 'hendrix/extension'

module Hendrix
  def self.logger() = SolidSupport.logger
  class Error < StandardError; end
end
