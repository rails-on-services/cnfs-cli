# frozen_string_literal: true

module Concerns
  module Interpolate
    extend ActiveSupport::Concern

    def cnfs_sub
      return as_json unless owner

      owner_hash = owner.cnfs_sub
      this_hash = as_json.compact.deep_transform_values do |value|
        value.cnfs_sub(owner_hash, owner_hash['config']) #, skip_raise: true) }
      end

      # binding.pry
      # this_hash = as_json.deep_transform_values { |value| value&.cnfs_sub(owner_hash) } #, skip_raise: true) }
      owner_hash.merge(this_hash)
    end
    # Custom string interpolation using the ${<text>} pattern
    # For each interpolation, pass an object reference (default is Cnfs module) to send the referenced values
    #
    # ==== Examples
    # '${project.name}'.cnfs_sub
    # '${project.environment.name}'.cnfs_sub
    # '${project.name} and ${project.environment.name}'.cnfs_sub
    #
    # Assuming that service is a referencable object, return service.name:
    # '${name}'.cnfs_sub(service)
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def z_cnfs_sub(*references, string: nil, skip_raise: false)
      return string unless (interpolations_to_replace = string.scan(/\${(.*?)}/).flatten).any?
      binding.pry if interpolations_to_replace.size > 1

      if interpolations_to_replace.size > references.size
        reference_to_append = references.size.positive? ? references.last : self
        (interpolations_to_replace.size - references.size).times { references.append(reference_to_append) }
      end

      return_string = string
      interpolations_to_replace.each do |interpolation|
        reference = references.shift
        interpolation_array = interpolation.split('.')
        while (next_interpolated_reference = interpolation_array.shift)
          reference = if reference.is_a? Hash
                        reference[next_interpolated_reference]
                      else
                        reference = reference.send(next_interpolated_reference)
                      end
        end
        return_string = return_string.gsub("${#{interpolation}}", reference)
      end
      return_string
    rescue TypeError => _e
      nil
    rescue NoMethodError => e
      raise e unless skip_raise

      string
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
  end
end
