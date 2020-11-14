# frozen_string_literal: true

module Cnfs
  module Plugins
    class <%= name.classify %>
      class << self
        def initialize_<%= name %>
          require 'cnfs/cli/<%= name %>'
          Cnfs::Cli::<%= name.classify %>.safe_constantize&.initialize
        end
      end
    end
  end
end
