# frozen_string_literal: true

require 'cnfs/version'

module Cnfs
  class Error < StandardError; end

  class << self
    def gem_root; Pathname.new(File.expand_path('../..', __FILE__)) end
  end
end
