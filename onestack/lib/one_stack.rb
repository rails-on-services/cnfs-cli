# frozen_string_literal: true

# require 'hendrix'
# module Hendrix
#   class Extension
#     ABSTRACT_EXTENSIONS = %w[OneStack::Extension OneStack::Plugin OneStack::Application Hendrix::Extension Hendrix::Plugin Hendrix::Application].freeze
#   end
# end
require 'solid_record'

require 'one_stack/version'
require 'one_stack/application'
require 'one_stack/plugin'
require 'one_stack/extension'

module OneStack
  def self.logger() = SolidSupport.logger
end
