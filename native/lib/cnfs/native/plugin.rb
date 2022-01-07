# frozen_string_literal: true

module Cnfs
  module Native
    class Plugin < Cnfs::Plugin
      def self.gem_root() = Cnfs::Native.gem_root
    end
  end
end
