# frozen_string_literal: false

# String interpolation using a dot reference notation with ${} delimter pattern
#
# For each interpolation, pass a reference hash to search for the interpolated string
#
# @example one top level key
#
#   hash = { project: { domain: 'example.com' } }
#   'host.${project.domain}'.interpolate(**hash) # => 'host.example.com'
#
#   hash = { project: { host: 'api', domain: 'test.com' } }
#   '${project.host}.${project.domain}'.interpolate(**hash) # => 'api.test.com'
#
# @example multiple top level keys
#
#   hash = { project: { name: 'test' }, admin: { tld: 'io' } }
#   'host.${project.name}.${admin.tld}'.interpolate(**hash) # => 'host.test.io'
#
#
# @example default and additional top level keys
#
#   # If a top level key is named 'default' the 'default' predicate is not necessary in the interpolated string
#
#   hash = { default: { host: 'test', domain: 'example' }, parent: { tld: 'io' } }
#   '${host}.${domain}.${parent.tld}'.interpolate(**hash) # => 'test.example.io'
class String
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/AbcSize

  # Interpolate a string with values from a Hash
  def interpolate(**references)
    # Return the original string if no references were passed in
    return self if references.empty?

    interpolations = scan(/\${(.*?)}/).flatten

    # Return the original string if no interpolations are found in the string
    return self unless interpolations.any?

    references.deep_transform_keys!(&:to_s)

    references.each do |key, param|
      next if param.is_a?(Hash)

      raise ArgumentError, "argument must by of type Hash (param #{key}, type #{param.class})"
    end

    # If one of the references keys is default then remove the default key and put its values at the root of the Hash
    i_reference = if references.key?('default')
                    references.except('default').merge(references['default'])
                  else
                    references
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

    # If the string has changed, an interpolation may have been replaced with another interpolation
    # So recursively invoke interpolate on the return_string
    return_string.interpolate(**references)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/AbcSize

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
