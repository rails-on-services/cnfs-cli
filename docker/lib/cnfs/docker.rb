# frozen_string_literal: true

require 'docker'
require 'docker/compose'

require 'cnfs/docker/version'
require 'cnfs/docker/plugin'

module Compose; end
module Docker
  module Concerns; end
end

module Cnfs
  module Docker
    def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
  end
end
