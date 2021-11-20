# frozen_string_literal: true

require 'cnfs_cli/native/version'

module CnfsCli
  module Native
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end
    end
  end
end
