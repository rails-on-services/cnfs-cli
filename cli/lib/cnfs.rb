# frozen_string_literal: true

require 'pathname'
require 'little-plugger'
require_relative 'cnfs_plugger'

module Cnfs
  extend LittlePlugger
  extend CnfsPlugger
  # Required by LittlePlugger
  module Plugins; end

  class Error < StandardError; end
end
