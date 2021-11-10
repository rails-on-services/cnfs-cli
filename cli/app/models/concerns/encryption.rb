# frozen_string_literal: true

module Concerns
  module Encryption
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :attr_encrypted

      def attr_encrypted(*attrs)
        @encrypted_attrs ||= []
        @encrypted_attrs.append(*attrs)
      end
    end

    # Returns an encrypted string
    #
    # ==== Parameters
    # plaintext<String>:: the string to be encrypted
    def encrypt(plaintext = nil)
      action(:encrypt, plaintext)
    end

    def decrypt(ciphertext = nil)
      action(:decrypt, ciphertext)
    rescue Lockbox::DecryptionError => e
      Cnfs.logger.warn(e.message)
      self
    end

    private

    def action(method, text)
      if text.nil?
        self.class.attr_encrypted.each { |attr| action_attr(method, attr) }
        self
      elsif has_attribute?(text)
        action_attr(method, text)
      else
        box.send(method, text)
        # encrypt_file(key_file, attributes.to_yaml)
        # rubocop:disable Security/YAMLLoad
        # YAML.load(decrypt_file("#{key_file}.enc"))
        # rubocop:enable Security/YAMLLoad
      end
    end

    def action_attr(method, attr)
      return unless (value = send(attr))
      binding.pry if value.is_a? Hash
      binding.pry if method.eql?(:encrypt) && value.encoding.to_s.eql?('ASCII-8BIT')
      return if method.eql?(:encrypt) && value.encoding.to_s.eql?('ASCII-8BIT')
      return if method.eql?(:decrypt) && !value.encoding.to_s.eql?('ASCII-8BIT')

      # binding.pry
     
      send("#{attr}=", box.send(method, value)) #.force_encoding("UTF-8")) #encrypt(send(attr)))
    end

    # def encrypt_file(file_name, plaintext = nil)
    #   plaintext ||= File.read(file_name)
    #   File.open("#{file_name}.enc", 'w') { |f| f.write(box.encrypt(plaintext)) }
    # end

    # def decrypt_file(file_name)
    #   ciphertext = File.binread(file_name)
    #   box.decrypt(ciphertext).chomp
    # end

    def box
      @box ||= Lockbox.new(key: key)
    end
  end
end
