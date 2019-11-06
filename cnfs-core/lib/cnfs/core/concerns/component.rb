# frozen_string_literal: true

module Cnfs::Core::Concerns
  module Component
    attr_accessor :partition, :resources

    def self.included(base)
      base.include Common
    end

    def initialize(partition)
      @partition = partition
      @resources = []
      children.each do |resource|
        self.class.send(:attr_accessor, resource)
        klass_name = "#{self.class.name}::#{resource.camelize}"
        init_obj = klass_name.constantize.new(self)
        instance_variable_set("@#{resource}", init_obj)
        @resources << instance_variable_get("@#{resource}")
      end
    end

    def parent; partition end
    def platform; partition.platform end

    def path_for(type = :deployments, resource: nil)
      parent.path_for(type, component: name, resource: resource)
    end
  end
end
