# frozen_string_literal: true

# External dependencies
require 'active_support/concern'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/introspection'
require 'active_support/inflector'
require 'active_support/notifications'
require 'active_support/time'

require_relative 'ext/hash'
require_relative 'ext/open_struct'
require_relative 'ext/pathname'
require_relative 'ext/string'

module SolidSupport
  class Error < StandardError; end
end
