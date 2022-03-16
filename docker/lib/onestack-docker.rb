# frozen_string_literal: true

require 'docker'
require 'docker/compose'

require_relative 'one_stack/docker/version'
require_relative 'one_stack/docker/plugin'

module Compose; end
module Docker
  module Concerns; end
end

module OneStack
  module Docker
    class << self
      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

      def config() = @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
