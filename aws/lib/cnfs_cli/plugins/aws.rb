# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Aws
      class << self
        def initialize_aws
          require 'cnfs_cli/aws'
          plugin_lib.initialize
        end

        def plugin_lib
          CnfsCli::Aws
        end
      end
    end
  end
end
