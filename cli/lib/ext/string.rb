# frozen_string_literal: true

class String
  YAML_STRING = "--- !binary |-\n  "

  def ciphertext(strip: false)
    strip ? encrypt(self).gsub(YAML_STRING, '').chomp : encrypt(self)
  end

  def plaintext(force: false)
    encrypted? ? decrypt(self) : (force ? decrypt("#{YAML_STRING} #{self}\n") : self)
  end

  def encrypted?; start_with?(YAML_STRING) end

  def cnfs_sub(target = nil)
    return self unless target

    self.gsub('{domain}', target.domain_name)
  end

  private

  # to_yaml converts from hex to string
  def encrypt(plaintext); Cnfs.box.encrypt(plaintext).to_yaml end

  # YAML.load converts from string to hex
  def decrypt(ciphertext); Cnfs.box.decrypt(YAML.load(ciphertext)) end
end
