# frozen_string_literal: false

class String
  # Custom string interpolation using the ${<text>} pattern
  # For each interpolation, pass a hash to search for the interpolated string
  #
  # ==== Examples
  # '${project.name}'.cnfs_sub(hash)
  # '${project.environment.name}'.cnfs_sub(hash)
  # '${project.name} and ${project.environment.name}'.cnfs_sub(hash)
  #
  # Assuming that service is a referencable object, return service.name:
  # '${name}'.cnfs_sub(service)
  #
  # reference is an Hash of one or more Hashes upon which lookups are performed
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize
  def cnfs_sub(**reference)
    # Return the original string if no reference were passed in
    return self if reference.empty?

    interpolations = scan(/\${(.*?)}/).flatten

    # Return the original string if no interpolations are found in the string
    return self unless interpolations.any?

    reference.transform_keys!(&:to_s)

    reference.each do |key, param|
      next if param.is_a?(Hash)

      raise ArgumentError, "argument must by of type Hash (param #{key}, type #{param.class})"
    end

    # If one of the reference keys is 'default' then remove the 'default' key and put its values at the root of the Hash
    i_reference = if reference.key?('default')
                    reference.except('default').merge(reference['default'])
                  else
                    reference
                  end

    return_string = self
    interpolations.each do |interpolation|
      next unless interpolation.length.positive?

      sub_string = search_reference(i_reference, interpolation)
      next unless sub_string.is_a? String

      return_string = return_string.gsub("${#{interpolation}}", sub_string)
    end

    # If after interpolation the string has not changed then return itself
    return self if return_string.eql?(self)

    # If the string has changed an interpolation may have been replaced with another interpolation
    # So recursively invoke cnfs_sub on the return_string
    return_string.cnfs_sub(**reference)
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  def search_reference(reference, interpolation)
    interpolation.split('.').each do |value|
      # reference must continue to be a Hash or Object otherwise it will fail when send is called
      break if reference.is_a? String

      break unless (reference = reference.is_a?(Hash) ? reference[value] : reference.send(value))
    end
    reference
  end
end
