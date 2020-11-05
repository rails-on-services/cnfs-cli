# frozen_string_literal: true

module Cnfs
  module Plugins
    class Infra
      class << self
        def initialize_infra
          require 'cnfs/cli/infra'
          plugin_lib.initialize
        end

        def plugin_lib
          Cnfs::Cli::Infra
        end
      end
    end
  end
end
