# frozen_string_literal: true

module SolidRecord
  module Encryption
    extend ActiveSupport::Concern

    class_methods do
      def attr_encrypted(*attrs) = encrypted_attrs.append(*attrs)

      def encrypted_attrs() = @encrypted_attrs ||= []
    end

    included { before_validation :decrypt_attrs }

    # Classes including this module can override this method to provide a key from an alternative location
    def encryption_key() = SolidRecord.config.encryption_key || Lockbox.generate_key

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

    # @return [Hash] Persistence#as_solid with all encrypted_attrs encrypted
    def as_solid() = with_attrs_encrypted { super }

    # Iterate over encrypted_attrs encrypting each attribute, yield to the caller then decrypt each attribute
    def with_attrs_encrypted
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

    # @param plaintext [String] text to be encrypted
    # @return [String] encrypted plaintext
    def encrypt(plaintext) = box.encrypt(plaintext)

    # @param ciphertext [String] encrypted text
    # @return [String] decrypted plaintext
    def decrypt(ciphertext)
      box.decrypt(ciphertext)
    rescue Lockbox::DecryptionError => e
      SolidRecord.raise_or_warn(e)
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
