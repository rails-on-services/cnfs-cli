# frozen_string_literal: true

module Cnfs
  module Plugins
    class <%= name.classify %>
      class << self
        def initialize_<%= name %>
          require 'cnfs/cli/<%= name %>'
          plugin_lib.initialize
        end

        def plugin_lib
          Cnfs::Cli::<%= name.classify %>
        end
      end
    end
  end
end
