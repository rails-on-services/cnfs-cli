# frozen_string_literal: false

class String
  YAML_STRING = "--- !binary |-\n  ".freeze

  # Return an encrypted string
  #
  # ==== Examples
  # 'abc'.ciphertext
  #
  # ==== Parameters
  # strip<Boolean>:: Remove the leading YAML binary text
  #
  def ciphertext(strip: false)
    strip ? encrypt(self).gsub(YAML_STRING, '').chomp : encrypt(self)
  end

  # Convert an encrypted string to a plaintext string
  #
  # ==== Examples
  # ciphertext.plaintext
  #
  # ==== Parameters
  # strip<Boolean>:: Remove the leading YAML binary text
  #
  def plaintext(force: false)
    return decrypt(self) if encrypted?

    force ? decrypt("#{YAML_STRING} #{self}\n") : self
  end

  def encrypted?
    start_with?(YAML_STRING)
  end

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

  # to_yaml converts from hex to string
  def encrypt(plaintext, scope = :namespace)
    Cnfs.project.encrypt(plaintext, scope).to_yaml
  end

  # YAML.load converts from string to hex
  def decrypt(ciphertext)
    Cnfs.project.decrypt(YAML.safe_load(ciphertext))
  end
end
