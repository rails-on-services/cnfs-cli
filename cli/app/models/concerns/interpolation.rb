# frozen_string_literal: true

module Concerns
	module Interpolation
		extend ActiveSupport::Concern

		def as_interpolated(method: :as_merged)
			this_hash = send(method).compact
			parent_hash = owner&.as_interpolated(method: method) || {}

			this_hash.deep_transform_values do |value|
				next value unless value.is_a? String

				value.cnfs_sub(default: this_hash, parent: parent_hash)
			end
		end

		class_methods do
			def obj_attrs
				@obj_attrs ||= Set.new
			end

			def attr_obj(*attrs)
				attrs.each do |method_name|
					obj_attrs << method_name.to_s
					# binding.pry if name.eql?('Resource')
					define_method(method_name.to_sym) do |**args|
						# hash = super(**args)
						# Cnfs.logger.warn(self.class.name, name, hash)
						value = instance_variable_get("@#{method_name}")
						# Cnfs.logger.warn(self.class.name, name, value)
						# value ||= instance_variable_set("@#{method_name}", Config::Options.new.merge!(hash))
						value ||= instance_variable_set("@#{method_name}", Config::Options.new.merge!(super(**args)))
					end
				end
			end
		end

		# store :envs, accessors: %i[platform], coder: YAML

		# def do_it
		# 	envs.keys.each do |key|
		# 		define_singleton_method(key.to_sym) { values[key] }
		# 		define_singleton_method("#{key}=".to_sym) { |name| values[key] = name }
		# 	end
		# end

		def x_as_json
			attrs = self.class.obj_attrs
			r_hash = attrs.each_with_object({}) do |attr, hash|
				Cnfs.logger.warn(self.class.name, name, attr, hash)
				hash[attr] = (instance_variable_get("@#{attr}") || {}).to_hash.deep_stringify_keys
			end
			# binding.pry if name.eql?('instance')
			super.except(*attrs).merge(r_hash)
		end
	end
end
