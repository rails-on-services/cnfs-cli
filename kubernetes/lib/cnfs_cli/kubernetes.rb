# frozen_string_literal: true

require 'cnfs_cli/kubernetes/version'

module CnfsCli
  module Kubernetes
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end
    end
  end
end
