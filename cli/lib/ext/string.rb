# frozen_string_literal: false

class String
  YAML_STRING = "--- !binary |-\n  ".freeze

  def ciphertext(strip: false)
    strip ? encrypt(self).gsub(YAML_STRING, '').chomp : encrypt(self)
  end

  def plaintext(force: false)
    encrypted? ? decrypt(self) : (force ? decrypt("#{YAML_STRING} #{self}\n") : self)
  end

  def encrypted?
    start_with?(YAML_STRING)
  end

  def cnfs_sub(*objs)
    return self unless objs.any? && (replace_ary = scan(/\${(.*?)}/).flatten)

    str = self
    replace_ary.each do |replace_string|
      ac = replace_string.split('.')
      obj = objs.shift
      while (cmd = ac.shift)
        obj = obj.send(cmd)
      end
      str = str.gsub("${#{replace_string}}", obj)
    end
    str
  end

  private

  # to_yaml converts from hex to string
  def encrypt(plaintext, scope = :namespace)
    Cnfs.application.encrypt(plaintext, scope).to_yaml
  end

  # YAML.load converts from string to hex
  def decrypt(ciphertext)
    Cnfs.application.decrypt(YAML.safe_load(ciphertext))
  end
end
