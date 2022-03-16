# frozen_string_literal: true

require 'ruby-terraform'

require_relative 'one_stack/terraform/version'
require_relative 'one_stack/terraform/plugin'

# Core Extensions
require_relative 'ext/hash'

module Terraform
  module Concerns; end
end

module OneStack
  module Terraform
    class << self
      def gem_root() = @gem_root ||= Pathname.new(__dir__).join('..')

      def config() = @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
