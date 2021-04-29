# frozen_string_literal: true

module Concerns
  module Key
    extend ActiveSupport::Concern

    included do
      before_create :prepare_for_create
      after_create :write_key
      after_destroy :remove_paths
    end

    def prepare_for_create
      self.key ||= Lockbox.generate_key
      save_path.split.first.mkpath
    end

    def write_key
      user_save_path.split.first.mkpath
      File.open(user_save_path, 'w') { |f| f.write("---\nkey: #{key}\n") }
    end

    def remove_paths
      [save_path, user_save_path].each do |path|
        path = path.split.first
        path.rmtree if path.exist?
      end
    end

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

    private

    def box
      @box ||= Lockbox.new(key: key)
    end
  end
end
