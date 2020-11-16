# frozen_string_literal: true

module Cnfs
  module Plugins
    class Rails
      class << self
        def initialize_rails
          require 'cnfs/cli/rails'
          plugin_lib.initialize
        end

        def plugin_lib
          Cnfs::Cli::Rails
        end
      end
    end
  end
end
