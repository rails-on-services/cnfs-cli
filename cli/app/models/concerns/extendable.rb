# frozen_string_literal: true

# Extendable should be included last as it includes plugin modules that may depend on methods
# defined in previously loaded modules
module Concerns
  module Extendable
    extend ActiveSupport::Concern

    included do
      # Plugins that have an appropriately named A/S Concern will be automatically included
      #
      # Example:
      # The terraform plugin adds methods to the Resource model by including A/S Concern in the module
      # Terraform::Resource declared in file CnfsCli::Terraform.gem_root/app/models/terraform/resource.rb
      Cnfs.modules_for(mod: CnfsCli, klass: self).each { |mod| include mod }
    end
  end
end
