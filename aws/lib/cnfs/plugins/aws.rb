# frozen_string_literal: true

module Cnfs
  module Plugins
    class Aws
      class << self
        def initialize_aws
          require 'cnfs/cli/aws'
          Cnfs::Cli::Aws.initialize
        end
      end
    end
  end
end
