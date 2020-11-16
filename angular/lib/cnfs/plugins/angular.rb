# frozen_string_literal: true

module Cnfs
  module Plugins
    class Angular
      class << self
        def initialize_angular
          require 'cnfs/cli/angular'
          Cnfs::Cli::Angular.initialize
        end
      end
    end
  end
end
