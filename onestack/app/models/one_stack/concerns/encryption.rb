# frozen_string_literal: true

module OneStack::Concerns
  module Encryption
    extend ActiveSupport::Concern

    class_methods do
      def attr_encrypted(*attrs)
        encrypted_attrs.append(*attrs)
      end

      def encrypted_attrs
        @encrypted_attrs ||= []
      end
    end

    included do
      before_validation :decrypt_attrs
    end

    # When a Node creates a new record it passes in raw yaml which may include encrypted values
    # In the model all encrypted values are decrypted befoer saving so that:
    #
    # 1. The attribute has the decrypted value for processing, and
    # 2. The encrypted value is not stored in the data store which would require columns to be of type binary
    #
    # This method iterates over all encrypted_attrs and:
    #
    # 1. If the attribute has ASCII-8BIT encoding it assigns the decrypted value to the attribute
    # 2. If the attribute has any other encoding it ignores the attribute and leaves the value in place
    #
    def decrypt_attrs
      self.class.encrypted_attrs.each do |attr|
        next unless (value = send(attr))

        send("#{attr}=", decrypt(value)) if value.encoding.to_s.eql?('ASCII-8BIT')
      end
    end

    # Return as_json with all encrypted_attrs fields encrypted
    # Used for saving the object to the filesystem
    def as_json_encrypted
      with_encrypted_attrs { as_json }
    end

    # Encrypt each encrypted_attr, yield to the caller then decrypt each encrypted_attr
    def with_encrypted_attrs
      self.class.encrypted_attrs.each do |attr|
        next unless (value = send(attr))

        send("#{attr}=", encrypt(value))
      end

      ret_val = yield if block_given?

      self.class.encrypted_attrs.each do |attr|
        next unless (value = send(attr))

        send("#{attr}=", decrypt(value))
      end

      ret_val
    end

    # Returns an encrypted string
    #
    # ==== Parameters
    # plaintext<String>:: the string to be encrypted
    def encrypt(plaintext)
      box.encrypt(plaintext)
    end

    def decrypt(ciphertext)
      box.decrypt(ciphertext)
    rescue Lockbox::DecryptionError => e
      Hendrix.logger.warn(e.message)
      nil
    end

    # def encrypt_file(file_name, plaintext = nil)
    #   plaintext ||= File.read(file_name)
    #   File.open("#{file_name}.enc", 'w') { |f| f.write(box.encrypt(plaintext)) }
    # end

    # def decrypt_file(file_name)
    #   ciphertext = File.binread(file_name)
    #   box.decrypt(ciphertext).chomp
    # end

    private

    def box
      @box ||= Lockbox.new(key: key)
    end
  end
end
