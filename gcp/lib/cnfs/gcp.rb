# frozen_string_literal: true

require 'cnfs/gcp/version'
require 'cnfs/gcp/plugin'

module Gcp
  module Concerns; end
end

module Cnfs
  module Gcp
    def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
  end
end
