# frozen_string_literal: true

module Cnfs
  module Plugins
    class Backend
      class << self
        def initialize_backend
          require 'cnfs/cli/backend'
          mod.setup
        end

        def mod
          Cnfs::Cli::Backend
        end
      end
    end
  end
end
