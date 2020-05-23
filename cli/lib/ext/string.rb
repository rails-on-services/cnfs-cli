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

  def cnfs_sub(target = nil)
    a = dup
    if target
      a.gsub!('{domain}', target.domain_name)
      a.gsub!('{domain_slug}', target.domain_slug)
    end
    # puts a
    # binding.pry if a.index('{project_name}')
    a.gsub!('{project_name}', Cnfs.application.class.name.underscore.split('/').shift)
    begin
      if Cnfs.request
        a.gsub!('{application_name}', Cnfs.request.args.application_name) if a.index('{application_name}')
        # binding.pry if a.index('{namespace}')
        if a.index('{namespace}') && Cnfs.request.args.namespace_name
          a.gsub!('{namespace}', Cnfs.request.args.namespace_name)
        end
      end
    rescue TypeError => e
      binding.pry
    end

    a
  end

  private

  # to_yaml converts from hex to string
  def encrypt(plaintext)
    Cnfs.box.encrypt(plaintext).to_yaml
  end

  # YAML.load converts from string to hex
  def decrypt(ciphertext)
    Cnfs.box.decrypt(YAML.safe_load(ciphertext))
  end
end
