# frozen_string_literal: true

module OneStack
  module Terraform
    class Plugin < Hendrix::Tune
      def self.gem_root() = OneStack::Terraform.gem_root
    end
  end
end
