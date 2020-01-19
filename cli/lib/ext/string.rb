# frozen_string_literal: false

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
    a = self.dup
    if target
      a.gsub!('{domain}', target.domain_name)
      a.gsub!('{domain_slug}', target.domain_slug)
    end
    a.gsub!('{project_name}', Cnfs.config.name)
    # binding.pry if a.index('{project_name}')
    if Cnfs.request
      a.gsub!('{application_name}', Cnfs.request.args.application_name)
    # binding.pry if a.index('{namespace}')
      a.gsub!('{namespace}', Cnfs.request.args.namespace_name)
    end
    a
  end

  private

  # to_yaml converts from hex to string
  def encrypt(plaintext); Cnfs.box.encrypt(plaintext).to_yaml end

  # YAML.load converts from string to hex
  def decrypt(ciphertext); Cnfs.box.decrypt(YAML.load(ciphertext)) end
end
