# frozen_string_literal: true

module OneStack
  module Kubernetes
    class Plugin < OneStack::Plugin
      config.before_initialize { |config| OneStack::Kubernetes.config.merge!(config.kubernetes) }

      def self.gem_root() = OneStack::Kubernetes.gem_root
    end
  end
end
