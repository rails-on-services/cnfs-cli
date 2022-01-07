# frozen_string_literal: true

require 'kubeclient'

require_relative 'kubernetes/version'
require_relative 'kubernetes/plugin'

module Kubernetes
  module Concerns; end
end

module Skaffold; end
module Compose; end

module Cnfs
  module Kubernetes
    def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
  end
end
