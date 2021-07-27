# frozen_string_literal: true

require 'cnfs_cli/aws/version'

module CnfsCli
  module Aws
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end
    end
  end
end
