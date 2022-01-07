# frozen_string_literal: true

require_relative 'aws/version'
require_relative 'aws/plugin'

module Aws
  module Concerns; end
end

module Cnfs
  module Aws
    def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
  end
end
