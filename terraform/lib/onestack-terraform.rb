# frozen_string_literal: true

require 'ruby-terraform'

require_relative 'one_stack/terraform/version'
require 'one_stack/terraform/plugin'

# Core Extensions
require_relative 'ext/hash'

module Terraform
  module Concerns; end
end

module OneStack
  module Terraform
    def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
  end
end
