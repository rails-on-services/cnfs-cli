# frozen_string_literal: true

module Cnfs
  module Plugins
    class Cloud
      def self.initialize_cloud
        require 'cnfs/cli/cloud'
        Cnfs::Cli::Cloud.setup
      end
    end
  end
end
