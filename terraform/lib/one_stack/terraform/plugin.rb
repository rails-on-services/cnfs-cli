# frozen_string_literal: true

module OneStack
  module Terraform
    class Plugin < OneStack::Plugin
      config.before_initialize { |config| OneStack::Terraform.config.merge!(config.terraform) }

      def self.gem_root() = OneStack::Terraform.gem_root
    end
  end
end
