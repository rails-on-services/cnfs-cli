# frozen_string_literal: true

module Cnfs
  module Plugins
    class Aws
      class << self
        def initialize_aws
          require 'cnfs/cli/aws'
          plugin_lib.initialize
        end

        def plugin_lib
          Cnfs::Cli::Aws
        end
      end
    end
  end
end
