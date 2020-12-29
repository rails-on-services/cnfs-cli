# frozen_string_literal: true

require 'cnfs_cli/gcp/version'

module CnfsCli
  module Gcp
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end

      def initialize
        Cnfs.logger.info "[Gcp] Initializing from #{gem_root}"
      end

      # TODO: Copy in blueprints, etc
      def customize; end
    end
  end
end
