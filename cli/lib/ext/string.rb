# frozen_string_literal: true

class String
  def ciphertext(strip: false)
    strip ? encrypt(self).gsub("--- !binary |-\n  ", '').chomp : encrypt(self)
  end

  def plaintext(force: false)
    encrypted? ? decrypt(self) : (force ? decrypt("--- !binary |-\n  #{self}\n") : self)
  end

  def encrypted?; start_with?("--- !binary |-\n  ") end

  def cnfs_sub(target = nil)
    return self unless target

    # string = self.dup
    # string.gsub!('{domain}', target.domain_name)
    self.gsub('{domain}', target.domain_name)
  end

  private

  # to_yaml converts from hex to string
  def encrypt(plaintext); Cnfs.box.encrypt(plaintext).to_yaml end

  # YAML.load converts from string to hex
  def decrypt(ciphertext); Cnfs.box.decrypt(YAML.load(ciphertext)) end
end
