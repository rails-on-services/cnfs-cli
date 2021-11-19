# frozen_string_literal: true

module Terraform
  module Resource
    extend ActiveSupport::Concern

    included do
      # binding.pry
    end

    # NOTE: used in TF templates
    def module_name
      resource_name.underscore
    end

    # The fields that the builder should output upon creating the resource
    def outputs
      []
    end

    # From Aws::Resource::RDS to RDS
    def service_name
      self.class.name.demodulize
    end

    def to_hcl
      as_hcl.to_hcl.join("\n")
    end

    def as_hcl
      as_json.merge(config_as_hcl).except(*except_hcl)
    end

    def except_hcl
      %w[provisioner_name provider_name runtime_name config envs type]
    end

    def config_as_hcl
      self.class.stored_attributes[:config].each_with_object({}) do |accessor, hash|
        hash[accessor.to_s] = send(accessor)
      end
    end
  end
end
