# frozen_string_literal: true

module Cnfs
  module Terraform
    class Plugin < Cnfs::Plugin
      def self.gem_root() = Cnfs::Terraform.gem_root
    end
  end
end
