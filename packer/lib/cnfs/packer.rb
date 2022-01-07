# frozen_string_literal: true

require_relative 'packer/version'
require_relative 'packer/plugin'

module Packer
  module Concerns; end
end

module Cnfs
  module Packer
    def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
  end
end
