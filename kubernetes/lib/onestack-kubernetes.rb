# frozen_string_literal: true

require 'kubeclient'

require_relative 'one_stack/kubernetes/version'
require_relative 'one_stack/kubernetes/plugin'

module Kubernetes
  module Concerns; end
end

module Skaffold; end
module Compose; end

module OneStack
  module Kubernetes
    class << self
      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

      def config() = @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
