# frozen_string_literal: true

module Cnfs
  module Plugins
    class Gcp
      class << self
        def initialize_gcp
          require 'cnfs/cli/gcp'
          plugin_lib.initialize
        end

        def plugin_lib
          Cnfs::Cli::Gcp
        end
      end
    end
  end
end
