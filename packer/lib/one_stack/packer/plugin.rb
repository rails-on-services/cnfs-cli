# frozen_string_literal: true

module OneStack
  module Packer
    class Plugin < OneStack::Plugin
      config.before_initialize { |config| OneStack::Packer.config.merge!(config.packer) }

      def self.gem_root() = OneStack::Packer.gem_root
    end
  end
end
