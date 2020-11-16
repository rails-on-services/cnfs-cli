# frozen_string_literal: true

module Cnfs
  module Plugins
    class CnfsBackend
      class << self
        def initialize_cnfs_backend
          require 'cnfs/cli/cnfs_backend'
          Cnfs::Cli::CnfsBackend.initialize
        end
      end
    end
  end
end
