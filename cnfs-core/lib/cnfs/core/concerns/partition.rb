# frozen_string_literal: true

module Cnfs::Core::Concerns
	module Partition
		attr_reader :platform, :components

		def self.included(base)
			base.include Common
		end

		def initialize(platform)
			@platform = platform
			@components = []
			children.each do |child|
				self.class.send(:attr_accessor, child)
        klass_name = "#{self.class.name}::#{child.camelize}"
        init_obj = klass_name.constantize.new(self)
				instance_variable_set("@#{child}", init_obj)
				@components << instance_variable_get("@#{child}")
			end
		end

		def parent; platform end

		def path_for(type = :deployments, component: nil, resource: nil)
			parent.path_for(type, partition: name, component: component, resource: resource)
		end
	end
end
