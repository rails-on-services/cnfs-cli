# frozen_string_literal: true

require 'cnfs_cli/docker/version'

module CnfsCli
  module Docker
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end
    end
  end
end
