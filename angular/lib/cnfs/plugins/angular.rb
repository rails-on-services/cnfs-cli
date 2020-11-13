# frozen_string_literal: true

module Cnfs
  module Plugins
    class Angular
      class << self
        def initialize_angular
          require 'cnfs/cli/angular'
          name.gsub('Plugins', 'Cli').safe_constantize&.initialize
        end
      end
    end
  end
end
