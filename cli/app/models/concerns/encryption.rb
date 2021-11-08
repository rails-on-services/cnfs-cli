# frozen_string_literal: true

module Concerns
  module Encryption
    extend ActiveSupport::Concern

    # Returns an encrypted string
    #
    # ==== Parameters
    # plaintext<String>:: the string to be encrypted
    def encrypt(plaintext = nil, attr: nil)
      if plaintext
        box.encrypt(plaintext)
      elsif attr
        send("#{attr}=", box.encrypt(send(attr)))
      else
        encrypt_file(key_file, attributes.to_yaml)
      end
    end

    def decrypt(ciphertext = nil, attr: nil)
      if ciphertext
        box.decrypt(ciphertext)
      elsif attr
        box.decrypt(send(attr))
      else
        # rubocop:disable Security/YAMLLoad
        YAML.load(decrypt_file("#{key_file}.enc"))
        # rubocop:enable Security/YAMLLoad
      end
    rescue Lockbox::DecryptionError => e
      Cnfs.logger.warn(e.message)
      nil
    end

    def encrypt_file(file_name, plaintext = nil)
      plaintext ||= File.read(file_name)
      File.open("#{file_name}.enc", 'w') { |f| f.write(box.encrypt(plaintext)) }
    end

    def decrypt_file(file_name)
      ciphertext = File.binread(file_name)
      box.decrypt(ciphertext).chomp
    end

    private

    def box
      @box ||= Lockbox.new(key: key)
    end
  end
end
