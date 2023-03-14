# frozen_string_literal: true

require_relative 'one_stack/gcp/version'

require 'onestack'

require_relative 'one_stack/gcp/plugin'

module Gcp
  module Concerns; end
end

module OneStack
  module Gcp
    class << self
      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

      def config() = @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
