# frozen_string_literal: true

require_relative 'one_stack/packer/version'

require 'onestack'

require_relative 'one_stack/packer/plugin'

module Packer
  module Concerns; end
end

module OneStack
  module Packer
    class << self
      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

      def config() = @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
