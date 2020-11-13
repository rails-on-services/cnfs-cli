# frozen_string_literal: true

module Cnfs
  module Plugins
    class Gcp
      class << self
        def initialize_gcp
          require 'cnfs/cli/gcp'
          name.gsub('Plugins', 'Cli').safe_constantize&.initialize
        end
      end
    end
  end
end
