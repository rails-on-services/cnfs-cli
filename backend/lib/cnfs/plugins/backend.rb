# frozen_string_literal: true

module Cnfs
  module Plugins
    class Backend
      class << self
        def initialize_backend
          require 'cnfs/cli/backend'
          plugin_lib.initialize
        end

        def plugin_lib
          Cnfs::Cli::Backend
        end
      end
    end
  end
end
