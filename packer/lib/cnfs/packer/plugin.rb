# frozen_string_literal: true

module Cnfs
  module Packer
    class Plugin < Cnfs::Plugin
      def self.gem_root() = Cnfs::Packer.gem_root
    end
  end
end
