# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Angular
      class << self
        def initialize_angular
          require 'cnfs_cli/angular'
          plugin_lib.initialize
        end

        def plugin_lib
          CnfsCli::Angular
        end
      end
    end
  end
end
