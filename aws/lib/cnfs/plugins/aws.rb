# frozen_string_literal: true

module Cnfs
  module Plugins
    class Aws
      class << self
        def initialize_aws
          require 'cnfs/cli/aws'
          name.gsub('Plugins', 'Cli').safe_constantize&.initialize
        end
      end
    end
  end
end
