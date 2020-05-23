# frozen_string_literal: true

module Cnfs
  module Plugins
    class Infra
      def self.initialize_infra
        require 'cnfs/cli/infra'
        Cnfs::Cli::Infra.setup
      end
    end
  end
end
