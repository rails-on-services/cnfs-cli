# frozen_string_literal: true

module OneStack
  module Gcp
    class Plugin < OneStack::Plugin
      config.before_initialize { |config| OneStack::Gcp.config.merge!(config.gcp) }

      def self.gem_root() = OneStack::Gcp.gem_root
    end
  end
end
