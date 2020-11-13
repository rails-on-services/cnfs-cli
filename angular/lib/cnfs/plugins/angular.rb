# frozen_string_literal: true

module Cnfs
  module Plugins
    class Angular
      class << self
        def initialize_angular
          require 'cnfs/cli/angular'
          plugin_lib.initialize
        end

        def plugin_lib
          Cnfs::Cli::Angular
        end
      end
    end
  end
end
