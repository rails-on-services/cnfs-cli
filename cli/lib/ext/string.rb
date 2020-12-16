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
    encrypted? ? decrypt(self) : (force ? decrypt("#{YAML_STRING} #{self}\n") : self)
  end

  def encrypted?
    start_with?(YAML_STRING)
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
  def cnfs_sub(*references, skip_raise: false)
    return self unless (interpolations_to_replace = scan(/\${(.*?)}/).flatten)

    if interpolations_to_replace.size > references.size 
      reference_to_append = references.size.positive? ? references.last : Cnfs
      (interpolations_to_replace.size - references.size).times { references.append(reference_to_append) }
    end

    return_string = self
    interpolations_to_replace.each do |interpolation|
      reference = references.shift
      interpolation_array = interpolation.split('.')
      while (next_interpolated_reference = interpolation_array.shift)
        reference = reference.send(next_interpolated_reference)
      end
      return_string = return_string.gsub("${#{interpolation}}", reference)
    end
    return_string
  rescue TypeError => e
     nil
  rescue NoMethodError => e
    raise e unless skip_raise
    self
  end

  private

  # to_yaml converts from hex to string
  def encrypt(plaintext, scope = :namespace)
    Cnfs.project.encrypt(plaintext, scope).to_yaml
  end

  # YAML.load converts from string to hex
  def decrypt(ciphertext)
    Cnfs.project.decrypt(YAML.safe_load(ciphertext))
  end
end
