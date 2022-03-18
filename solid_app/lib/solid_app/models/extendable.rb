# frozen_string_literal: true

# Extendable should be included last as it includes plugin modules that may depend on methods
# defined in previously loaded modules
module SolidApp
  module Extendable
    extend ActiveSupport::Concern

    included do
      # Plugins that have an appropriately named A/S Concern will be automatically included
      #
      # Example:
      # The terraform plugin adds methods to the Resource model by including A/S Concern in the module
      # Terraform::Concerns::Resource declared in file Terraform.gem_root/app/models/terraform/concerns/resource.rb
      # SolidApp.modules_for(self).each { |mod| include mod }
    end
  end
end
