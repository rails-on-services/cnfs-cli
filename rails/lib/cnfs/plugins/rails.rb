# frozen_string_literal: true

module Cnfs
  module Plugins
    class Rails
      class << self
        def initialize_rails
          require 'cnfs/cli/rails'
          Cnfs::Cli::Rails.initialize
        end
      end
    end
  end
end
