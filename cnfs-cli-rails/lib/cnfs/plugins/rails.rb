# frozen_string_literal: true

module Cnfs
  module Plugins
    class Rails
      def self.initialize_rails
        require 'cnfs/cli/rails'
        Cnfs::Cli::Rails.setup
      end
    end
  end
end
