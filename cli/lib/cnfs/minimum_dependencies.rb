# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/introspection'
require 'active_support/inflector'
require 'fileutils'
require 'thor'
require 'thor/hollaback'
require 'zeitwerk'

require_relative 'errors'
require_relative 'version'
require_relative '../ext/config/options'
require_relative '../ext/string'
