# frozen_string_literal: true

module Cnfs
  module Gcp
    class Plugin < Cnfs::Plugin
      def self.gem_root() = Cnfs::Gcp.gem_root
    end
  end
end
