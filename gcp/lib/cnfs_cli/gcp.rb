# frozen_string_literal: true

require 'cnfs_cli/gcp/version'

module CnfsCli
  module Gcp
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end
    end
  end
end
