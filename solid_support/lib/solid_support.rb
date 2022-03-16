# frozen_string_literal: true

# External dependencies
require 'active_support/concern'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/introspection'
require 'active_support/inflector'
require 'active_support/notifications'
require 'active_support/time'
require 'tty-tree'

require_relative 'ext/hash'
require_relative 'ext/open_struct'
require_relative 'ext/pathname'
require_relative 'ext/string'

require_relative 'solid_support/interpolation'
require_relative 'solid_support/tree_view'

require_relative 'solid_support/models/command'
require_relative 'solid_support/models/command_queue'
require_relative 'solid_support/models/download'
require_relative 'solid_support/models/extendable'
require_relative 'solid_support/models/git'

module SolidSupport
  class Error < StandardError; end
end
