# frozen_string_literal: true

class Key < ApplicationRecord
  def encrypt(plaintext)
    box.encrypt(plaintext)
  end

  def decrypt(ciphertext)
    box.decrypt(ciphertext)
  end

  def encrypt_file(file_name)
    plaintext = File.read(file_name)
    File.open("#{file_name}.enc", 'w') { |f| f.write(box.encrypt(plaintext)) }
  end

  def decrypt_file(file_name)
    ciphertext = File.binread(file_name)
    box.decrypt(ciphertext).chomp
  end

  class << self
    # TODO: Implement
    def parse
      # Key.parse([user_root.join('config').to_s])
    end
  end

  private

  def box
    @box ||= Lockbox.new(key: value)
  end
end
