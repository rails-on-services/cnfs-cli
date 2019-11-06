# frozen_string_literal: true

module Cnfs::Core::Concerns
  module Resource
    attr_accessor :component #, :units

    def self.included(base)
      base.include Common
    end

    def initialize(component)
      @component = component
    end

    # Empty method to be implemented by each resource class
    def generate; end

    def parent; component end
    def platform; component.platform end

    def path_for(type = :deployments)
      parent.path_for(type, resource: name)
    end
  end
end
