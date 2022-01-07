# frozen_string_literal: true

module Cnfs
  module Kubernetes
    class Plugin < Cnfs::Plugin
      def self.gem_root() = Cnfs::Kubernetes.gem_root
    end
  end
end
