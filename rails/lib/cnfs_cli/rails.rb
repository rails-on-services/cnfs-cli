# frozen_string_literal: true

require 'cnfs_cli/rails/version'

module CnfsCli
  module Rails
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end
    end
  end
end
