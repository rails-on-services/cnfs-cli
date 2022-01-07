# frozen_string_literal: true

require 'ruby-terraform'

require 'cnfs/terraform/version'
require 'cnfs/terraform/plugin'

# Core Extensions
require_relative '../ext/hash'

module Terraform
  module Concerns; end
end

module Cnfs
  module Terraform
    def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
  end
end
