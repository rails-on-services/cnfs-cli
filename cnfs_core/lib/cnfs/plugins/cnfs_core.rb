# frozen_string_literal: true

module Cnfs
  module Plugins
    class CnfsCore
      class << self
        def initialize_cnfs_core
          require 'cnfs/cli/cnfs_core'
          plugin_lib.initialize
        end

        def plugin_lib
          Cnfs::Cli::CnfsCore
        end
      end
    end
  end
end
