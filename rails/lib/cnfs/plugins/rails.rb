# frozen_string_literal: true

module Cnfs
  module Plugins
    class Rails
      class << self
        def initialize_rails
          require 'cnfs/cli/rails'
          name.gsub('Plugins', 'Cli').safe_constantize&.initialize
        end
      end
    end
  end
end
