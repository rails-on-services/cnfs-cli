# frozen_string_literal: true

module SolidRecord
  module Encryption
    extend ActiveSupport::Concern

    class_methods do
      def attr_encrypted(*attrs) = encrypted_attrs.append(*attrs)

      def encrypted_attrs() = @encrypted_attrs ||= []
    end

    included { before_validation :decrypt_attrs }

    # Classes including this module should override this method to provide a consistent key from a known location
    def encryption_key() = Lockbox.generate_key

    # When a new record is created it passes in raw yaml which may include encrypted values
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

    # @return [Hash] with all encrypted_attrs fields encrypted
    def as_solid() = with_encrypted_attrs { super }

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
      SolidRecord.logger.warn { e.message }
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

    def box() = @box ||= Lockbox.new(key: encryption_key)
  end
end
