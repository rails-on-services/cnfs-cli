# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Gcp
      class << self
        def initialize_gcp
          require 'cnfs_cli/gcp'
          plugin_lib.initialize
        end

        def plugin_lib
          CnfsCli::Gcp
        end
      end
    end
  end
end
