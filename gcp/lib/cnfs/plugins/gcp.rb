# frozen_string_literal: true

module Cnfs
  module Plugins
    class Gcp
      class << self
        def initialize_gcp
          require 'cnfs/cli/gcp'
          Cnfs::Cli::Gcp.initialize
        end
      end
    end
  end
end
