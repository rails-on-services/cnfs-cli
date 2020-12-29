# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Rails
      class << self
        def initialize_rails
          require 'cnfs_cli/rails'
          plugin_lib.initialize
        end

        def plugin_lib
          CnfsCli::Rails
        end
      end
    end
  end
end
