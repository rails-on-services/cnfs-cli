# frozen_string_literal: true

require 'ruby-terraform'

require 'cnfs_cli/terraform/version'

module CnfsCli
  module Terraform
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end
    end
  end
end
