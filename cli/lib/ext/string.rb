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

  def cnfs_sub
    return self unless (context = Cnfs.context)

    a = dup
    if (target = context.target)
      a.gsub!('{domain}', target.domain_name)
      a.gsub!('{domain_slug}', target.domain_slug)
    end
    # bind = a.index('{project_name}')
    a.gsub!('{project_name}', context.project_name_attrs.join('-'))
    # binding.pry if bind
    # begin
      if a.index('{application_name}') && context.application&.name
        a.gsub!('{application_name}', context.application.name)
      elsif a.index('{namespace}') && context.namespace&.name
        a.gsub!('{namespace}', context.namespace.name)
      end
    # rescue TypeError => e
    #   binding.pry
    # end
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
