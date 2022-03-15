# frozen_string_literal: true

require_relative 'one_stack/aws/version'

require 'onestack'

require_relative 'one_stack/aws/plugin'

module Aws
  module Concerns; end
end

module OneStack
  module Aws
    class << self
      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

      def config() = @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
