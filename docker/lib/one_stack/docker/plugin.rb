# frozen_string_literal: true

module OneStack
  module Docker
    class Plugin < OneStack::Plugin
      config.before_initialize { |config| OneStack::Docker.config.merge!(config.docker) }

      def self.gem_root() = OneStack::Docker.gem_root
    end
  end
end
