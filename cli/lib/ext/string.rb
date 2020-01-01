# frozen_string_literal: true

class String
  def ciphertext(strip_yaml = false); Cnfs.encrypt(self, strip_yaml) end

  def plaintext(strip_yaml = false); encrypted? || strip_yaml ? Cnfs.decrypt(self, strip_yaml) : self end

  def encrypted?; start_with?("--- !binary |-\n  ") end

  def cnfs_sub(target = nil)
    return self unless target

    string = self
    string.gsub!('{domain}', target.domain_name)
  end
end
