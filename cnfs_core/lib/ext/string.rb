# frozen_string_literal: false

class String
  # Custom string interpolation using the ${<text>} pattern
  # For each interpolation, pass an array of object references to search for the interpolated string
  #
  # ==== Examples
  # '${project.name}'.cnfs_sub(hash)
  # '${project.environment.name}'.cnfs_sub(hash)
  # '${project.name} and ${project.environment.name}'.cnfs_sub(hash)
  #
  # Assuming that service is a referencable object, return service.name:
  # '${name}'.cnfs_sub(service)
  #
  def cnfs_sub(*references) # , skip_raise: false)
    return self unless (interpolations = scan(/\${(.*?)}/).flatten) && references.any?

    return_string = self
    interpolations.each do |interpolation|
      next unless (sub_string = search_references(references, interpolation))

      return_string = return_string.gsub("${#{interpolation}}", sub_string)
    end
    return_string
  end

  private

  def search_references(references, interpolation)
    references.each do |reference|
      if (replaced = try_reference(reference, interpolation))
        return replaced
      end
    end
    nil
  end

  def try_reference(reference, interpolation)
    interpolation.split('.').each do |value|
      return unless (reference = reference.is_a?(Hash) ? reference[value] : reference.send(value))
    end
    reference
  rescue NoMethodError # Swallow error if reference.is_a?(Integer TrueClass FalseClass)
  end
end
